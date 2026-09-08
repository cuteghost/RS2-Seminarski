import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/models/reservation_model.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/authorized_image.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';
import 'package:ebooking_desktop/widgets/pagination_control.dart';
import 'package:ebooking_desktop/widgets/reservation_status_tag.dart';

final _dateFormat = DateFormat('dd.MM.yyyy');
final _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');
final _money = NumberFormat.currency(locale: 'bs', symbol: 'KM ', decimalDigits: 2);

/// Prelazi koje administrator smije izvesti.
const _allowedTransitions = <ReservationStatus, List<ReservationStatus>>{
  ReservationStatus.pending: [
    ReservationStatus.confirmed,
    ReservationStatus.rejected,
    ReservationStatus.cancelled,
  ],
  ReservationStatus.confirmed: [
    ReservationStatus.cancelled,
    ReservationStatus.completed,
  ],
  ReservationStatus.cancelled: [],
  ReservationStatus.rejected: [],
  ReservationStatus.completed: [],
};

class ManageReservationsPage extends StatefulWidget {
  const ManageReservationsPage({super.key});

  @override
  State<ManageReservationsPage> createState() => _ManageReservationsPageState();
}

class _ManageReservationsPageState extends State<ManageReservationsPage> {
  static const _searchDebounce = Duration(milliseconds: 400);

  final _searchController = TextEditingController();
  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.text = context.read<AdminProvider>().reservationQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, () {
      if (!mounted) return;
      context.read<AdminProvider>().setReservationQuery(value);
    });
  }

  Future<void> _pickRange(AdminProvider admin) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: admin.reservationStart != null && admin.reservationEnd != null
          ? DateTimeRange(start: admin.reservationStart!, end: admin.reservationEnd!)
          : null,
      helpText: 'Reservation period',
      saveText: 'Apply',
    );
    if (picked == null || !mounted) return;

    try {
      await admin.setReservationRange(picked.start, picked.end);
    } catch (e) {
      if (!mounted) return;
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.reservationsLoading &&
            admin.reservationsList.isEmpty &&
            admin.reservationsError == null) {
          return const SectionScaffold(
            child: NLoading(label: 'Loading reservations…'),
          );
        }

        final items = admin.reservationsList;
        final rangeLabel = admin.reservationStart == null
            ? 'Entire period'
            : '${_dateFormat.format(admin.reservationStart!)} – '
                '${_dateFormat.format(admin.reservationEnd!)}';

        return SectionScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NPageHeader(
                title: 'Reservations',
                subtitle: '${admin.reservationsTotalCount} reservations in '
                    'the selected period.',
                actions: [
                  OutlinedButton.icon(
                    onPressed: admin.reservationsLoading ? null : admin.loadReservations,
                    icon: Icon(PhosphorIcons.arrowsClockwise(), size: 14),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.x6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: NSearchField(
                      controller: _searchController,
                      hint: 'Search by property name',
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: AppSpace.x3),
                  NDropdown<ReservationStatus?>(
                    width: 190,
                    value: admin.reservationStatusFilter,
                    hint: 'All statuses',
                    onChanged: admin.setReservationStatusFilter,
                    items: [
                      const DropdownMenuItem<ReservationStatus?>(
                          value: null, child: Text('All statuses')),
                      for (final status in ReservationStatus.values)
                        DropdownMenuItem<ReservationStatus?>(
                          value: status,
                          child: Text(status.label),
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSpace.x3),
                  OutlinedButton.icon(
                    onPressed: () => _pickRange(admin),
                    icon: Icon(PhosphorIcons.calendarBlank(), size: 14),
                    label: Text(rangeLabel),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.x4),
              if (admin.reservationsError != null)
                NErrorState(
                  message: admin.reservationsError!,
                  onRetry: admin.loadReservations,
                )
              else ...[
                NCard(
                  padding: EdgeInsets.zero,
                  clip: true,
                  child: _ReservationTable(items: items, admin: admin),
                ),
                const SizedBox(height: AppSpace.x4),
                NPaginationControl(
                  page: admin.reservationsPage,
                  totalPages: admin.reservationsTotalPages,
                  totalCount: admin.reservationsTotalCount,
                  pageSize: admin.reservationsPageSize,
                  onPageChanged: admin.setReservationsPage,
                  onPageSizeChanged: admin.setReservationsPageSize,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ReservationTable extends StatelessWidget {
  final List<ReservationGET> items;
  final AdminProvider admin;

  const _ReservationTable({required this.items, required this.admin});

  @override
  Widget build(BuildContext context) {
    return NTable(
      columns: const [
        NColumn('', width: 52),
        NColumn('Property', flex: 3),
        NColumn('Guest', flex: 2),
        NColumn('Dates', width: 190),
        NColumn('Guests', width: 80, align: Alignment.centerRight),
        NColumn('Amount', width: 140, align: Alignment.centerRight),
        NColumn('Status', width: 130),
        NColumn('Paid', width: 90),
        NColumn('', width: 110, align: Alignment.centerRight),
      ],
      rowCount: items.length,
      empty: const NEmptyState(
        message: 'No reservations for the selected period and filters.',
      ),
      cellsBuilder: (context, index) {
        final item = items[index];
        final status = item.status;

        return [
          SizedBox(
            width: 40,
            height: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppColors.radiusSm),
              child: AuthorizedImage(
                path: item.thumbnailUrl ?? '',
                token: admin.imageToken,
                width: 40,
                height: 30,
              ),
            ),
          ),
          Text(
            item.accommodation?.name ?? 'Unknown property',
            overflow: TextOverflow.ellipsis,
          ),
          NMutedCell(item.guest?.displayName.isNotEmpty == true
              ? item.guest!.displayName
              : '—'),
          NMutedCell('${_dateFormat.format(item.startDate)} – '
              '${_dateFormat.format(item.endDate)}'),
          NMutedCell('${item.numberOfGuests}'),
          Text(_money.format(item.revenue)),
          status == null
              ? const NMutedCell('—')
              : NTag(status.label, variant: reservationTagVariant(status)),
          item.isPaid
              ? const NTag('Yes', variant: NTagVariant.accent)
              : const NMutedCell('No'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              NIconAction(
                icon: PhosphorIcons.clockCounterClockwise(),
                tooltip: 'History and payment',
                onPressed: () => _openHistory(context, item),
              ),
              _TransitionAction(item: item, admin: admin),
            ],
          ),
        ];
      },
    );
  }

  void _openHistory(BuildContext context, ReservationGET item) {
    showDialog<void>(
      context: context,
      barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
      builder: (_) => _HistoryDialog(reservation: item),
    );
  }
}

class _TransitionAction extends StatelessWidget {
  final ReservationGET item;
  final AdminProvider admin;

  const _TransitionAction({required this.item, required this.admin});

  @override
  Widget build(BuildContext context) {
    final status = item.status;
    final allowed = status == null ? const <ReservationStatus>[] : _allowedTransitions[status]!;

    if (allowed.isEmpty) {
      return NIconAction(
        icon: PhosphorIcons.arrowsLeftRight(),
        tooltip: 'Change status',
        disabledReason: status == null
            ? 'The reservation has no recognized status, so a transition cannot be offered.'
            : 'The reservation is in the final status ${status.label.toLowerCase()} '
                'and can no longer be changed.',
        onPressed: null,
      );
    }

    return NIconAction(
      icon: PhosphorIcons.arrowsLeftRight(),
      tooltip: 'Change status',
      onPressed: () => _openTransition(context, allowed),
    );
  }

  Future<void> _openTransition(
    BuildContext context,
    List<ReservationStatus> allowed,
  ) async {
    final result = await showDialog<({ReservationStatus status, String reason})>(
      context: context,
      barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
      builder: (_) => _TransitionDialog(item: item, allowed: allowed),
    );
    if (result == null || !context.mounted) return;

    try {
      final message = await admin.changeReservationStatus(
        reservationId: item.id,
        status: result.status,
        reason: result.reason,
      );
      if (context.mounted) nToast(context, message);
    } catch (e) {
      if (context.mounted) {
        nToast(context, ApiResponseHandler.describe(e), isError: true);
      }
    }
  }
}

class _TransitionDialog extends StatefulWidget {
  final ReservationGET item;
  final List<ReservationStatus> allowed;

  const _TransitionDialog({required this.item, required this.allowed});

  @override
  State<_TransitionDialog> createState() => _TransitionDialogState();
}

class _TransitionDialogState extends State<_TransitionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  late ReservationStatus _target = widget.allowed.first;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  bool get _reasonRequired => _target == ReservationStatus.rejected;

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context)
        .pop((status: _target, reason: _reason.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.item.status;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x6),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                NDialogHeader(
                  title: 'Change reservation status',
                  subtitle: '${widget.item.accommodation?.name ?? 'Property'} · '
                      'current: ${current?.label ?? 'unknown'}',
                ),
                const SizedBox(height: AppSpace.x6),
                NField(
                  label: 'New status',
                  child: DropdownButtonFormField<ReservationStatus>(
                    initialValue: _target,
                    isExpanded: true,
                    items: [
                      for (final status in widget.allowed)
                        DropdownMenuItem<ReservationStatus>(
                          value: status,
                          child: Text(status.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _target = value);
                    },
                  ),
                ),
                const SizedBox(height: AppSpace.x4),
                NField(
                  label: _reasonRequired ? 'Reason (required)' : 'Reason (optional)',
                  child: TextFormField(
                    controller: _reason,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: 'The reason is forwarded to the guest as a message.',
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (_reasonRequired && text.isEmpty) {
                        return 'Rejecting a reservation requires a reason that is '
                            'forwarded to the guest.';
                      }
                      if (text.length > 500) {
                        return 'The reason may have at most 500 characters.';
                      }
                      return null;
                    },
                  ),
                ),
                if (_target == ReservationStatus.completed) ...[
                  Text(
                    'The stay can only be completed after the checkout date '
                    '(${_dateFormat.format(widget.item.endDate)}).',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpace.x2),
                ],
                const SizedBox(height: AppSpace.x4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back'),
                    ),
                    const SizedBox(width: AppSpace.x3),
                    OutlinedButton(
                      onPressed: _save,
                      child: const Text('Change status'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryDialog extends StatefulWidget {
  final ReservationGET reservation;

  const _HistoryDialog({required this.reservation});

  @override
  State<_HistoryDialog> createState() => _HistoryDialogState();
}

class _HistoryDialogState extends State<_HistoryDialog> {
  late Future<List<ReservationStatusHistoryGET>> _history;
  late Future<({PaymentGET payment, String message})> _payment;

  @override
  void initState() {
    super.initState();
    final admin = context.read<AdminProvider>();
    _history = admin.historyFor(widget.reservation.id);
    _payment = admin.paymentFor(widget.reservation.id);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              NDialogHeader(
                title: 'Reservation history',
                subtitle: '${widget.reservation.accommodation?.name ?? 'Property'} · '
                    '${_dateFormat.format(widget.reservation.startDate)} – '
                    '${_dateFormat.format(widget.reservation.endDate)}',
              ),
              const SizedBox(height: AppSpace.x4),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const NKicker('Payment'),
                      const SizedBox(height: AppSpace.x3),
                      _PaymentBlock(future: _payment),
                      const SizedBox(height: AppSpace.x6),
                      const NKicker('Audit trail'),
                      const SizedBox(height: AppSpace.x3),
                      _HistoryBlock(future: _history),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.x6),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentBlock extends StatelessWidget {
  final Future<({PaymentGET payment, String message})> future;

  const _PaymentBlock({required this.future});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<({PaymentGET payment, String message})>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const NLoading(label: 'Loading payment status…');
        }
        if (snapshot.hasError) {
          return Text(
            ApiResponseHandler.describe(snapshot.error!),
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          );
        }

        final result = snapshot.data!;
        final payment = result.payment;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (result.message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.x3),
                child: Text(result.message, style: theme.textTheme.bodySmall),
              ),
            _Row(label: 'Status', value: payment.status.label),
            _Row(
              label: 'Amount',
              value: '${payment.amount.toStringAsFixed(2)} ${payment.currency}',
            ),
            _Row(
              label: 'Provider',
              value: payment.provider.isEmpty ? '—' : payment.provider,
            ),
            _Row(
              label: 'Paid',
              value: payment.completedAt == null
                  ? 'Not paid'
                  : _dateTimeFormat.format(payment.completedAt!),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryBlock extends StatelessWidget {
  final Future<List<ReservationStatusHistoryGET>> future;

  const _HistoryBlock({required this.future});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<ReservationStatusHistoryGET>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const NLoading(label: 'Loading audit trail…');
        }
        if (snapshot.hasError) {
          return Text(
            ApiResponseHandler.describe(snapshot.error!),
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          );
        }

        final rows = snapshot.data ?? const <ReservationStatusHistoryGET>[];
        if (rows.isEmpty) {
          return Text(
            'This reservation\'s status has not been changed.',
            style: theme.textTheme.bodySmall,
          );
        }

        final sorted = rows.toList()
          ..sort((a, b) => (b.changedAt ?? DateTime(0))
              .compareTo(a.changedAt ?? DateTime(0)));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in sorted) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${row.fromStatus?.label ?? 'Created'} → '
                      '${row.toStatus?.label ?? '—'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    row.changedAt == null
                        ? '—'
                        : _dateTimeFormat.format(row.changedAt!),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${row.changedByDisplayName}'
                '${row.changedByRole.isEmpty ? '' : ' · ${row.changedByRole}'}',
                style: theme.textTheme.bodySmall,
              ),
              if (row.reason.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text('Reason: ${row.reason}',
                    style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: AppSpace.x3),
            ],
          ],
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
