import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/models/accommodation_type.dart';
import 'package:ebooking_desktop/models/amenity.dart';
import 'package:ebooking_desktop/models/reservation_model.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/providers/reference_data_provider.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

class ReferenceDataPage extends StatefulWidget {
  const ReferenceDataPage({super.key});

  @override
  State<ReferenceDataPage> createState() => _ReferenceDataPageState();
}

class _ReferenceDataPageState extends State<ReferenceDataPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final reference = context.watch<ReferenceDataProvider>();

    return SectionScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NPageHeader(
            title: 'Reference Data',
            subtitle: 'Standardized values shared by all properties.',
            actions: [
              if (_tab != 1)
                OutlinedButton.icon(
                  onPressed: reference.isLoading
                      ? null
                      : () => _tab == 0
                          ? _openTypeForm(context, reference)
                          : _openAmenityForm(context, reference),
                  icon: Icon(PhosphorIcons.plus(), size: 14),
                  label: Text(_tab == 0 ? 'New type' : 'New amenity'),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.x6),
          NTabs(
            labels: const ['Property types', 'Reservation statuses', 'Amenities'],
            selected: _tab,
            onChanged: (index) => setState(() => _tab = index),
          ),
          const SizedBox(height: AppSpace.x4),
          if (reference.error != null && _tab != 1) ...[
            NErrorState(
              message: reference.error!,
              onRetry: reference.loadAll,
            ),
            const SizedBox(height: AppSpace.x4),
          ],
          NCard(
            padding: EdgeInsets.zero,
            clip: true,
            child: switch (_tab) {
              0 => _TypesTable(admin: admin, reference: reference),
              1 => _StatusesTable(admin: admin),
              _ => _AmenitiesTable(admin: admin, reference: reference),
            },
          ),
        ],
      ),
    );
  }
}

class _TypesTable extends StatelessWidget {
  final AdminProvider admin;
  final ReferenceDataProvider reference;

  const _TypesTable({required this.admin, required this.reference});

  @override
  Widget build(BuildContext context) {
    final types = reference.types;

    return NTable(
      columns: const [
        NColumn('Property type', flex: 3),
        NColumn('Order', width: 120, align: Alignment.centerRight),
        NColumn('Used by properties', width: 170, align: Alignment.centerRight),
        NColumn('', width: 76, align: Alignment.centerRight),
      ],
      rowCount: types.length,
      empty: const NEmptyState(
        message: 'No property types defined yet. Add the first type with the '
            '"New type" button.',
      ),
      cellsBuilder: (context, index) {
        final type = types[index];
        final used = admin.accommodations
            .where((a) => a.accommodationTypeId == type.id)
            .length;

        return [
          Text(type.name, overflow: TextOverflow.ellipsis),
          NMutedCell('${type.sortOrder}'),
          NMutedCell('$used'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              NIconAction(
                icon: PhosphorIcons.pencilSimple(),
                tooltip: 'Edit type',
                onPressed: () => _openTypeForm(context, reference, type: type),
              ),
              NIconAction(
                icon: PhosphorIcons.trash(),
                tooltip: 'Delete type',
                color: AppColors.error,
                onPressed: () => _deleteType(context, reference, type, used),
              ),
            ],
          ),
        ];
      },
    );
  }
}

class _AmenitiesTable extends StatelessWidget {
  final AdminProvider admin;
  final ReferenceDataProvider reference;

  const _AmenitiesTable({required this.admin, required this.reference});

  @override
  Widget build(BuildContext context) {
    final amenities = reference.amenities;

    final usage = <String, int>{};
    for (final accommodation in admin.accommodations) {
      for (final amenity in accommodation.accommodationDetails.amenities) {
        usage[amenity.id] = (usage[amenity.id] ?? 0) + 1;
      }
    }

    return NTable(
      columns: const [
        NColumn('Code', flex: 2),
        NColumn('Name', flex: 3),
        NColumn('Order', width: 120, align: Alignment.centerRight),
        NColumn('Used by properties', width: 170, align: Alignment.centerRight),
        NColumn('', width: 76, align: Alignment.centerRight),
      ],
      rowCount: amenities.length,
      empty: const NEmptyState(
        message: 'No amenities defined yet. Add the first amenity with the '
            '"New amenity" button.',
      ),
      cellsBuilder: (context, index) {
        final amenity = amenities[index];
        final used = usage[amenity.id] ?? 0;

        return [
          NMutedCell(amenity.code),
          Text(amenity.name, overflow: TextOverflow.ellipsis),
          NMutedCell('${amenity.sortOrder}'),
          NMutedCell('$used'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              NIconAction(
                icon: PhosphorIcons.pencilSimple(),
                tooltip: 'Edit amenity',
                onPressed: () =>
                    _openAmenityForm(context, reference, amenity: amenity),
              ),
              NIconAction(
                icon: PhosphorIcons.trash(),
                tooltip: 'Delete amenity',
                color: AppColors.error,
                onPressed: () =>
                    _deleteAmenity(context, reference, amenity, used),
              ),
            ],
          ),
        ];
      },
    );
  }
}

class _StatusesTable extends StatelessWidget {
  final AdminProvider admin;

  const _StatusesTable({required this.admin});

  static const _reason =
      'Reservation statuses are part of a state machine on the server '
      '(ReservationService.Transitions): each status has precisely defined '
      'allowed transitions. A new status requires a new transition in the code, '
      'so it cannot be added from the application.';

  @override
  Widget build(BuildContext context) {
    final counts = <ReservationStatus, int>{
      for (final status in ReservationStatus.values) status: 0,
    };
    var unknown = 0;

    for (final reservation in admin.reservations) {
      final status = reservation.status;
      if (status == null) {
        unknown++;
      } else {
        counts[status] = (counts[status] ?? 0) + 1;
      }
    }

    final rows = ReservationStatus.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NTable(
          columns: const [
            NColumn('Status', flex: 3),
            NColumn('Code', width: 100, align: Alignment.centerRight),
            NColumn('Reservations', width: 150, align: Alignment.centerRight),
            NColumn('', width: 76, align: Alignment.centerRight),
          ],
          rowCount: rows.length,
          empty: const NEmptyState(message: 'No statuses defined.'),
          cellsBuilder: (context, index) {
            final status = rows[index];
            return [
              Text(status.label),
              NMutedCell('${status.value}'),
              NMutedCell('${counts[status] ?? 0}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  NIconAction(
                    icon: PhosphorIcons.pencilSimple(),
                    tooltip: 'Edit',
                    disabledReason: _reason,
                    onPressed: null,
                  ),
                  NIconAction(
                    icon: PhosphorIcons.trash(),
                    tooltip: 'Delete',
                    color: AppColors.error,
                    disabledReason: _reason,
                    onPressed: null,
                  ),
                ],
              ),
            ];
          },
        ),
        if (unknown > 0)
          Padding(
            padding: const EdgeInsets.all(AppSpace.x4),
            child: Text(
              '$unknown reservations have no recognized status.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

Future<void> _openTypeForm(
  BuildContext context,
  ReferenceDataProvider reference, {
  AccommodationType? type,
}) async {
  final message = await showDialog<String>(
    context: context,
    barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
    builder: (_) => _TypeFormDialog(reference: reference, type: type),
  );

  if (message != null && context.mounted) nToast(context, message);
}

Future<void> _openAmenityForm(
  BuildContext context,
  ReferenceDataProvider reference, {
  Amenity? amenity,
}) async {
  final message = await showDialog<String>(
    context: context,
    barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
    builder: (_) => _AmenityFormDialog(reference: reference, amenity: amenity),
  );

  if (message != null && context.mounted) nToast(context, message);
}

Future<void> _deleteType(
  BuildContext context,
  ReferenceDataProvider reference,
  AccommodationType type,
  int used,
) async {
  final confirmed = await nConfirm(
    context,
    title: 'Delete property type',
    message: used == 0
        ? 'Delete type "${type.name}"? This action cannot be undone.'
        : 'Type "${type.name}" is currently used by $used properties. The server will '
            'reject the deletion until those properties are moved to another type.',
    confirmLabel: 'Delete',
  );
  if (!confirmed || !context.mounted) return;

  try {
    final message = await reference.deleteType(type.id);
    if (context.mounted) nToast(context, message);
  } on ApiException catch (e) {
    if (context.mounted) nToast(context, e.message, isError: true);
  } catch (e) {
    if (context.mounted) {
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    }
  }
}

Future<void> _deleteAmenity(
  BuildContext context,
  ReferenceDataProvider reference,
  Amenity amenity,
  int used,
) async {
  final confirmed = await nConfirm(
    context,
    title: 'Delete amenity',
    message: used == 0
        ? 'Delete amenity "${amenity.name}"? This action cannot be undone.'
        : 'Amenity "${amenity.name}" is linked to $used properties. The server will '
            'reject the deletion until those links are removed.',
    confirmLabel: 'Delete',
  );
  if (!confirmed || !context.mounted) return;

  try {
    final message = await reference.deleteAmenity(amenity.id);
    if (context.mounted) nToast(context, message);
  } on ApiException catch (e) {
    if (context.mounted) nToast(context, e.message, isError: true);
  } catch (e) {
    if (context.mounted) {
      nToast(context, ApiResponseHandler.describe(e), isError: true);
    }
  }
}

class _TypeFormDialog extends StatefulWidget {
  final ReferenceDataProvider reference;
  final AccommodationType? type;

  const _TypeFormDialog({required this.reference, this.type});

  @override
  State<_TypeFormDialog> createState() => _TypeFormDialogState();
}

class _TypeFormDialogState extends State<_TypeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _sortOrder;

  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.type != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.type?.name ?? '');
    _sortOrder = TextEditingController(
      text: '${widget.type?.sortOrder ?? widget.reference.nextTypeSortOrder}',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    final navigator = Navigator.of(context);
    final name = _name.text.trim();
    final sortOrder = int.parse(_sortOrder.text.trim());

    try {
      final message = _isEdit
          ? await widget.reference.updateType(
              id: widget.type!.id, name: name, sortOrder: sortOrder)
          : await widget.reference.addType(name: name, sortOrder: sortOrder);
      navigator.pop(message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = ApiResponseHandler.describe(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x6),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                NDialogHeader(
                  title: _isEdit ? 'Edit property type' : 'New property type',
                  subtitle: 'The name is shown in the property table and in filters.',
                ),
                const SizedBox(height: AppSpace.x6),
                NField(
                  label: 'Name',
                  child: TextFormField(
                    controller: _name,
                    autofocus: true,
                    enabled: !_saving,
                    decoration: const InputDecoration(hintText: 'e.g. Apartment'),
                    validator: _validateName,
                  ),
                ),
                const SizedBox(height: AppSpace.x4),
                NField(
                  label: 'Display order',
                  child: TextFormField(
                    controller: _sortOrder,
                    enabled: !_saving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 5'),
                    validator: _validateSortOrder,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpace.x4),
                  _FormError(message: _error!),
                ],
                const SizedBox(height: AppSpace.x6),
                _FormActions(
                  saving: _saving,
                  onCancel: () => Navigator.of(context).pop(),
                  onSave: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AmenityFormDialog extends StatefulWidget {
  final ReferenceDataProvider reference;
  final Amenity? amenity;

  const _AmenityFormDialog({required this.reference, this.amenity});

  @override
  State<_AmenityFormDialog> createState() => _AmenityFormDialogState();
}

class _AmenityFormDialogState extends State<_AmenityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _sortOrder;

  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.amenity != null;

  @override
  void initState() {
    super.initState();
    _code = TextEditingController(text: widget.amenity?.code ?? '');
    _name = TextEditingController(text: widget.amenity?.name ?? '');
    _sortOrder = TextEditingController(
      text: '${widget.amenity?.sortOrder ?? widget.reference.nextAmenitySortOrder}',
    );
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    final navigator = Navigator.of(context);
    final code = _code.text.trim();
    final name = _name.text.trim();
    final sortOrder = int.parse(_sortOrder.text.trim());

    try {
      final message = _isEdit
          ? await widget.reference.updateAmenity(
              id: widget.amenity!.id,
              code: code,
              name: name,
              sortOrder: sortOrder)
          : await widget.reference
              .addAmenity(code: code, name: name, sortOrder: sortOrder);
      navigator.pop(message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = ApiResponseHandler.describe(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x6),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                NDialogHeader(
                  title: _isEdit ? 'Edit amenity' : 'New amenity',
                  subtitle: 'The code is a technical key, the name is shown to users.',
                ),
                const SizedBox(height: AppSpace.x6),
                NField(
                  label: 'Code',
                  child: TextFormField(
                    controller: _code,
                    autofocus: !_isEdit,
                    enabled: !_saving,
                    decoration: const InputDecoration(hintText: 'e.g. Balcony'),
                    validator: (value) => _validateText(value, 2, 50, 'Code'),
                  ),
                ),
                if (_isEdit) ...[
                  const SizedBox(height: AppSpace.x2),
                  Text(
                    'Changing the code changes the technical key of the amenity. Existing '
                    'links to properties remain, but any integration that '
                    'recognizes the old code will no longer find it.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: AppSpace.x4),
                NField(
                  label: 'Name',
                  child: TextFormField(
                    controller: _name,
                    autofocus: _isEdit,
                    enabled: !_saving,
                    decoration: const InputDecoration(hintText: 'e.g. Balcony'),
                    validator: (value) => _validateText(value, 2, 80, 'Name'),
                  ),
                ),
                const SizedBox(height: AppSpace.x4),
                NField(
                  label: 'Display order',
                  child: TextFormField(
                    controller: _sortOrder,
                    enabled: !_saving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 12'),
                    validator: _validateSortOrder,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpace.x4),
                  _FormError(message: _error!),
                ],
                const SizedBox(height: AppSpace.x6),
                _FormActions(
                  saving: _saving,
                  onCancel: () => Navigator.of(context).pop(),
                  onSave: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _validateName(String? value) => _validateText(value, 2, 50, 'Name');

String? _validateText(String? value, int min, int max, String field) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return '$field is required and must have $min to $max characters.';
  if (text.length < min || text.length > max) {
    return '$field must have between $min and $max characters.';
  }
  return null;
}

String? _validateSortOrder(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Order is required and must be a whole number.';
  final parsed = int.tryParse(text);
  if (parsed == null) {
    return 'Order must be a whole number, without decimals or spaces.';
  }
  if (parsed < 0) return 'Order cannot be a negative number.';
  return null;
}

class _FormActions extends StatelessWidget {
  final bool saving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _FormActions({
    required this.saving,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: saving ? null : onCancel, child: const Text('Back')),
        const SizedBox(width: AppSpace.x3),
        OutlinedButton(
          onPressed: saving ? null : onSave,
          child: saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _FormError extends StatelessWidget {
  final String message;

  const _FormError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIcons.warningCircle(), size: 15, color: AppColors.error),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
