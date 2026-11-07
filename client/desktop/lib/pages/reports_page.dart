import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/models/report_model.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/services/auth_service.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/services/report_service.dart';
import 'package:ebooking_desktop/services/report_generator.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

/// Modul za izvještavanje: PDF izvještaji dostupni i za preuzimanje i za ispis
/// (najbolje ocijenjeni smještaji; rezervacije po gradovima i državama), uz
/// pregled istih podataka u aplikaciji prije generisanja dokumenta.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String? _busyReport;

  final ReportService _reportService =
      ReportService(secureStorage: SecureStorage());
  ReportInterval _interval = ReportInterval.month;
  late DateTime _to = DateTime.now();
  late DateTime _from = DateTime(_to.year - 1, _to.month + 1, 1);
  ReportOverview? _overview;
  String? _overviewError;
  bool _overviewLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    setState(() {
      _overviewLoading = true;
      _overviewError = null;
    });
    try {
      final overview = await _reportService.overview(
        from: _from,
        to: _to,
        interval: _interval,
      );
      if (!mounted) return;
      setState(() => _overview = overview);
    } catch (e) {
      if (!mounted) return;
      setState(() => _overviewError = ApiResponseHandler.describe(e));
    } finally {
      if (mounted) setState(() => _overviewLoading = false);
    }
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (picked == null) return;
    setState(() {
      _from = picked.start;
      _to = picked.end;
    });
    await _loadOverview();
  }

  Future<void> _run({
    required String id,
    required Future<Uint8List> Function() build,
    required String filename,
    required bool print,
  }) async {
    if (_busyReport != null) return;
    setState(() => _busyReport = id);

    try {
      final bytes = await build();
      if (!mounted) return;

      if (print) {
        await Printing.layoutPdf(
          onLayout: (_) async => bytes,
          name: filename,
        );
      } else {
        await Printing.sharePdf(bytes: bytes, filename: filename);
      }
    } catch (e) {
      if (!mounted) return;
      nToast(
        context,
        'Report generation failed. Check whether the '
        'printer is available and try again.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _busyReport = null);
    }
  }

  String _stamp() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.isLoading && !admin.hasData) {
          return const SectionScaffold(
            child: NLoading(label: 'Loading report data…'),
          );
        }

        return SectionScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const NPageHeader(
                title: 'Reports',
                subtitle: 'Overviews ready for download and printing in .pdf format.',
              ),
              const SizedBox(height: AppSpace.x6),
              _ServerOverviewReport(
                overview: _overview,
                loading: _overviewLoading,
                error: _overviewError,
                interval: _interval,
                from: _from,
                to: _to,
                busy: _busyReport,
                onIntervalChanged: (interval) {
                  setState(() => _interval = interval);
                  _loadOverview();
                },
                onPickRange: _pickRange,
                onRetry: _loadOverview,
                onDownload: () => _run(
                  id: 'overview',
                  print: false,
                  filename: 'ebooking-growth-turnover-${_stamp()}.pdf',
                  build: () => ReportGenerator.serverOverview(_overview!),
                ),
                onPrint: () => _run(
                  id: 'overview',
                  print: true,
                  filename: 'ebooking-growth-turnover-${_stamp()}.pdf',
                  build: () => ReportGenerator.serverOverview(_overview!),
                ),
              ),
              const SizedBox(height: AppSpace.x6),
              _TopRatedReport(
                admin: admin,
                busy: _busyReport,
                onDownload: () => _run(
                  id: 'top-rated',
                  print: false,
                  filename: 'ebooking-top-rated-${_stamp()}.pdf',
                  build: () =>
                      ReportGenerator.topRatedProperties(admin.accommodations),
                ),
                onPrint: () => _run(
                  id: 'top-rated',
                  print: true,
                  filename: 'ebooking-top-rated-${_stamp()}.pdf',
                  build: () =>
                      ReportGenerator.topRatedProperties(admin.accommodations),
                ),
              ),
              const SizedBox(height: AppSpace.x6),
              _ByCityReport(
                admin: admin,
                busy: _busyReport,
                onDownload: () => _run(
                  id: 'by-city',
                  print: false,
                  filename: 'ebooking-reservations-by-city-${_stamp()}.pdf',
                  build: () => _buildByCity(admin),
                ),
                onPrint: () => _run(
                  id: 'by-city',
                  print: true,
                  filename: 'ebooking-reservations-by-city-${_stamp()}.pdf',
                  build: () => _buildByCity(admin),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Uint8List> _buildByCity(AdminProvider admin) {
    final reservations = admin.reservations;
    final dates = reservations.map((r) => r.startDate).toList()..sort();
    final now = DateTime.now();

    return ReportGenerator.reservationsByCity(
      reservations,
      from: dates.isEmpty ? now : dates.first,
      to: dates.isEmpty ? now : dates.last,
    );
  }
}

/// Zaglavlje kartice izvještaja sa dugmadima "Preuzmi PDF" i "Štampaj".
class _ReportCardHeader extends StatelessWidget {
  final String kicker;
  final String title;
  final bool busy;
  final bool enabled;
  final String? disabledReason;
  final VoidCallback onDownload;
  final VoidCallback onPrint;

  const _ReportCardHeader({
    required this.kicker,
    required this.title,
    required this.busy,
    required this.enabled,
    required this.onDownload,
    required this.onPrint,
    this.disabledReason,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpace.x4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                NKicker(kicker),
                const SizedBox(height: AppSpace.x1),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpace.x4),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            Tooltip(
              message: disabledReason ?? 'Save the report as a .pdf file',
              child: OutlinedButton.icon(
                onPressed: enabled ? onDownload : null,
                icon: Icon(PhosphorIcons.downloadSimple(), size: 14),
                label: const Text('Download PDF'),
              ),
            ),
            const SizedBox(width: AppSpace.x2),
            Tooltip(
              message: disabledReason ?? 'Open the print dialog',
              child: TextButton.icon(
                onPressed: enabled ? onPrint : null,
                icon: Icon(PhosphorIcons.printer(), size: 14),
                label: const Text('Print'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Izvještaj 1
// ═══════════════════════════════════════════════════════════════════════════

class _TopRatedReport extends StatelessWidget {
  final AdminProvider admin;
  final String? busy;
  final VoidCallback onDownload;
  final VoidCallback onPrint;

  const _TopRatedReport({
    required this.admin,
    required this.busy,
    required this.onDownload,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    final ranked = admin.accommodations.where((a) => a.reviewScore > 0).toList()
      ..sort((a, b) => b.reviewScore.compareTo(a.reviewScore));
    final preview = ranked.take(5).toList();

    return NCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReportCardHeader(
            kicker: 'Report 01',
            title: 'Top-rated properties',
            busy: busy == 'top-rated',
            enabled: ranked.isNotEmpty,
            disabledReason: ranked.isEmpty
                ? 'Report unavailable: no property has a rating yet.'
                : null,
            onDownload: onDownload,
            onPrint: onPrint,
          ),
          NTable(
            columns: const [
              NColumn('Rank', width: 70),
              NColumn('Property', flex: 3),
              NColumn('City, country', flex: 3),
              NColumn('Rating', width: 90, align: Alignment.centerRight),
            ],
            rowCount: preview.length,
            empty: const NEmptyState(
              message: 'No property has a guest rating yet.',
            ),
            cellsBuilder: (context, index) {
              final item = preview[index];
              return [
                NMutedCell('#${index + 1}'),
                Text(item.name, overflow: TextOverflow.ellipsis),
                NMutedCell(item.location.placeLabel),
                Text(item.reviewScore.toStringAsFixed(1)),
              ];
            },
          ),
          if (ranked.length > preview.length)
            Padding(
              padding: const EdgeInsets.all(AppSpace.x4),
              child: Text(
                'Showing the first ${preview.length}. '
                'The PDF contains up to 20 top-rated properties.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Izvještaj 2
// ═══════════════════════════════════════════════════════════════════════════

class _ByCityReport extends StatelessWidget {
  final AdminProvider admin;
  final String? busy;
  final VoidCallback onDownload;
  final VoidCallback onPrint;

  const _ByCityReport({
    required this.admin,
    required this.busy,
    required this.onDownload,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    final money =
        NumberFormat.currency(locale: 'bs', symbol: 'KM ', decimalDigits: 0);

    final byCity = <String, ({String city, String country, int count, double revenue})>{};
    for (final reservation in admin.reservations) {
      final location = reservation.accommodation?.location;
      final city = (location?.cityName.isNotEmpty ?? false)
          ? location!.cityName
          : 'Unknown city';
      final country = (location?.countryName.isNotEmpty ?? false)
          ? location!.countryName
          : '—';
      final key = '$city|$country';
      final existing = byCity[key];
      byCity[key] = (
        city: city,
        country: country,
        count: (existing?.count ?? 0) + 1,
        revenue: (existing?.revenue ?? 0) + reservation.revenue,
      );
    }

    final rows = byCity.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final maxCount =
        rows.isEmpty ? 1 : rows.map((r) => r.count).reduce((a, b) => a > b ? a : b);

    return NCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReportCardHeader(
            kicker: 'Report 02',
            title: 'Reservations by city and country',
            busy: busy == 'by-city',
            enabled: rows.isNotEmpty,
            disabledReason: rows.isEmpty
                ? 'Report unavailable: no reservations recorded.'
                : null,
            onDownload: onDownload,
            onPrint: onPrint,
          ),
          if (rows.isEmpty)
            const NEmptyState(
              message: 'No reservations recorded for the available period.',
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.x4, 0, AppSpace.x4, AppSpace.x6),
              child: Column(
                children: [
                  for (final row in rows.take(6))
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.x4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    children: [
                                      TextSpan(text: row.city),
                                      TextSpan(
                                        text: '  ·  ${row.country}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                '${row.count} · ${money.format(row.revenue)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpace.x2),
                          NMeterBar(fraction: row.count / maxCount),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ServerOverviewReport extends StatelessWidget {
  final ReportOverview? overview;
  final bool loading;
  final String? error;
  final ReportInterval interval;
  final DateTime from;
  final DateTime to;
  final String? busy;
  final ValueChanged<ReportInterval> onIntervalChanged;
  final VoidCallback onPickRange;
  final VoidCallback onRetry;
  final VoidCallback onDownload;
  final VoidCallback onPrint;

  const _ServerOverviewReport({
    required this.overview,
    required this.loading,
    required this.error,
    required this.interval,
    required this.from,
    required this.to,
    required this.busy,
    required this.onIntervalChanged,
    required this.onPickRange,
    required this.onRetry,
    required this.onDownload,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final report = overview;
    final money = NumberFormat.currency(
        locale: 'en', symbol: '${report?.currency ?? 'USD'} ', decimalDigits: 2);

    return NCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReportCardHeader(
            kicker: 'Report 00',
            title: 'Growth and payment turnover',
            busy: busy == 'overview',
            enabled: report != null && !loading,
            disabledReason: report == null
                ? 'Report unavailable until the server data is loaded.'
                : null,
            onDownload: onDownload,
            onPrint: onPrint,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
            child: Wrap(
              spacing: AppSpace.x3,
              runSpacing: AppSpace.x2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SegmentedButton<ReportInterval>(
                  segments: [
                    for (final value in ReportInterval.values)
                      ButtonSegment(value: value, label: Text(value.label)),
                  ],
                  selected: {interval},
                  onSelectionChanged: loading
                      ? null
                      : (selection) => onIntervalChanged(selection.first),
                ),
                OutlinedButton.icon(
                  onPressed: loading ? null : onPickRange,
                  icon: Icon(PhosphorIcons.calendarBlank(), size: 14),
                  label: Text(
                      '${dateFormat.format(from)} – ${dateFormat.format(to)}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.x4),
          if (loading && report == null)
            const Padding(
              padding: EdgeInsets.all(AppSpace.x6),
              child: NLoading(label: 'Generating the report on the server…'),
            )
          else if (error != null && report == null)
            Padding(
              padding: const EdgeInsets.all(AppSpace.x4),
              child: NErrorState(message: error!, onRetry: onRetry),
            )
          else if (report != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
              child: Row(
                children: [
                  _Stat(label: 'New properties', value: '${report.newAccommodations}'),
                  _Stat(label: 'New users', value: '${report.newUsers}'),
                  _Stat(label: 'Payment turnover', value: money.format(report.totalRevenue)),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.x4),
            _ServerChart(svg: report.growthSvg),
            _ServerChart(svg: report.topCustomersSvg),
            _ServerChart(svg: report.topAccommodationsSvg),
            const SizedBox(height: AppSpace.x4),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NKicker(label),
          const SizedBox(height: AppSpace.x1),
          Text(value, style: textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _ServerChart extends StatelessWidget {
  final String svg;

  const _ServerChart({required this.svg});

  @override
  Widget build(BuildContext context) {
    if (svg.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.x4, AppSpace.x2, AppSpace.x4, AppSpace.x2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AspectRatio(
          aspectRatio: 800 / 360,
          child: SvgPicture.string(svg, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
