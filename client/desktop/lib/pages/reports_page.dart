import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/services/report_generator.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

/// Modul za izvještavanje.
///
/// Upute 2.2 traže minimalno dva .pdf izvještaja, dostupna i za PREUZIMANJE
/// i za ISPIS. Oba su implementirana:
///   1. Najbolje ocijenjeni smještaji
///   2. Rezervacije po gradovima i državama
///
/// Ekran prikazuje i pregled istih podataka u aplikaciji, da administrator
/// vidi šta će dobiti prije nego generiše dokument.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String? _busyReport;

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
        // Otvara sistemski dijalog za štampu (Upute 2.2 — "dostupna za ispis").
        await Printing.layoutPdf(
          onLayout: (_) async => bytes,
          name: filename,
        );
      } else {
        // Otvara sistemski "Sačuvaj kao" dijalog (Upute 2.2 — "za preuzimanje").
        await Printing.sharePdf(bytes: bytes, filename: filename);
      }
    } catch (e) {
      if (!mounted) return;
      nToast(
        context,
        'Generisanje izvještaja nije uspjelo. Provjerite da li je '
        'štampač dostupan i pokušajte ponovo.',
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
            child: NLoading(label: 'Učitavanje podataka za izvještaje…'),
          );
        }

        return SectionScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const NPageHeader(
                title: 'Izvještaji',
                subtitle: 'Pregledi spremni za preuzimanje i ispis u .pdf formatu.',
              ),
              const SizedBox(height: AppSpace.x6),
              _TopRatedReport(
                admin: admin,
                busy: _busyReport,
                onDownload: () => _run(
                  id: 'top-rated',
                  print: false,
                  filename: 'ebooking-najbolje-ocijenjeni-${_stamp()}.pdf',
                  build: () =>
                      ReportGenerator.topRatedProperties(admin.accommodations),
                ),
                onPrint: () => _run(
                  id: 'top-rated',
                  print: true,
                  filename: 'ebooking-najbolje-ocijenjeni-${_stamp()}.pdf',
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
                  filename: 'ebooking-rezervacije-po-gradovima-${_stamp()}.pdf',
                  build: () => _buildByCity(admin),
                ),
                onPrint: () => _run(
                  id: 'by-city',
                  print: true,
                  filename: 'ebooking-rezervacije-po-gradovima-${_stamp()}.pdf',
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
              message: disabledReason ?? 'Sačuvaj izvještaj kao .pdf datoteku',
              child: OutlinedButton.icon(
                onPressed: enabled ? onDownload : null,
                icon: Icon(PhosphorIcons.downloadSimple(), size: 14),
                label: const Text('Preuzmi PDF'),
              ),
            ),
            const SizedBox(width: AppSpace.x2),
            Tooltip(
              message: disabledReason ?? 'Otvori dijalog za štampu',
              child: TextButton.icon(
                onPressed: enabled ? onPrint : null,
                icon: Icon(PhosphorIcons.printer(), size: 14),
                label: const Text('Štampaj'),
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
            kicker: 'Izvještaj 01',
            title: 'Najbolje ocijenjeni smještaji',
            busy: busy == 'top-rated',
            enabled: ranked.isNotEmpty,
            disabledReason: ranked.isEmpty
                ? 'Izvještaj nije dostupan: nijedan smještaj još nema ocjenu.'
                : null,
            onDownload: onDownload,
            onPrint: onPrint,
          ),
          NTable(
            columns: const [
              NColumn('Rang', width: 70),
              NColumn('Smještaj', flex: 3),
              NColumn('Grad, država', flex: 3),
              NColumn('Ocjena', width: 90, align: Alignment.centerRight),
            ],
            rowCount: preview.length,
            empty: const NEmptyState(
              message: 'Nijedan smještaj još nema ocjenu gostiju.',
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
                'Prikazano prvih ${preview.length}. '
                'PDF sadrži do 20 najbolje ocijenjenih smještaja.',
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
          : 'Nepoznat grad';
      final country = (location?.countryName.isNotEmpty ?? false)
          ? location!.countryName
          : '—';
      final key = '$city|$country';
      final existing = byCity[key];
      byCity[key] = (
        city: city,
        country: country,
        count: (existing?.count ?? 0) + 1,
        revenue: (existing?.revenue ?? 0) + reservation.estimatedRevenue,
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
            kicker: 'Izvještaj 02',
            title: 'Rezervacije po gradovima i državama',
            busy: busy == 'by-city',
            enabled: rows.isNotEmpty,
            disabledReason: rows.isEmpty
                ? 'Izvještaj nije dostupan: nema evidentiranih rezervacija.'
                : null,
            onDownload: onDownload,
            onPrint: onPrint,
          ),
          if (rows.isEmpty)
            const NEmptyState(
              message: 'Za dostupan period nema evidentiranih rezervacija.',
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
