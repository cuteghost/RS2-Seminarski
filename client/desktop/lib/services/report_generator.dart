import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:ebooking_desktop/models/accomodation_model.dart';
import 'package:ebooking_desktop/models/reservation_model.dart';

/// Generisanje .pdf izvještaja.
///
/// Upute 2.2: "Potrebno je omogućiti minimalno dva izvještaja u .pdf formatu,
/// dostupna za preuzimanje i ispis." Desktop klijent ranije nije imao NIJEDAN
/// izvještaj — ovo je bio tvrdi blokirajući nedostatak.
///
/// Font: koristi se Inter iz `assets/fonts/`. Ugrađeni PDF font (Helvetica)
/// koristi WinAnsi enkodiranje koje NEMA naša slova (č, ć, š, ž, đ), pa bi
/// "Baščaršija" ili "Bosna i Hercegovina" bili pogrešno iscrtani. Ako font
/// iz nekog razloga nije dostupan, pada se nazad na Helveticu da generisanje
/// nikad ne pukne — samo se dijakritika izgubi.
class ReportGenerator {
  ReportGenerator._();

  static pw.ThemeData? _cachedTheme;

  /// Font se učitava jednom i keširа (Upute 8.2 — podatke koji se učitavaju
  /// na svaki zahtjev treba keširati).
  static Future<pw.ThemeData> _theme() async {
    if (_cachedTheme != null) return _cachedTheme!;
    try {
      final regular = pw.Font.ttf(
          await rootBundle.load('assets/fonts/Inter-Regular.ttf'));
      final medium = pw.Font.ttf(
          await rootBundle.load('assets/fonts/Inter-Medium.ttf'));
      final bold =
          pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Bold.ttf'));
      _cachedTheme = pw.ThemeData.withFont(
        base: regular,
        bold: bold,
        italic: regular,
        boldItalic: medium,
      );
    } catch (_) {
      _cachedTheme = pw.ThemeData.base();
    }
    return _cachedTheme!;
  }

  static final _dateFormat = DateFormat('dd.MM.yyyy');
  static final _dateTimeFormat = DateFormat('dd.MM.yyyy. HH:mm');
  static final _money =
      NumberFormat.currency(locale: 'bs', symbol: 'KM ', decimalDigits: 2);

  // Paleta izvještaja: PDF se štampa na bijelom papiru, pa se NE koristi
  // tamna Nocturne pozadina — preuzima se samo akcentna boja kao linija.
  static const _accent = PdfColor.fromInt(0xFF9184D9);
  static const _ink = PdfColor.fromInt(0xFF232532);
  static const _muted = PdfColor.fromInt(0xFF75798C);
  static const _rule = PdfColor.fromInt(0xFFCFD3E5);

  // ═════════════════════════════════════════════════════════════════════════
  // Izvještaj 1 — Najbolje ocijenjeni smještaji
  // ═════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> topRatedProperties(
    List<AccommodationGET> accommodations,
  ) async {
    final ranked = accommodations.where((a) => a.reviewScore > 0).toList()
      ..sort((a, b) => b.reviewScore.compareTo(a.reviewScore));
    final top = ranked.take(20).toList();

    final document = pw.Document(theme: await _theme());

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 44, 40, 48),
        header: (context) => _header(
          context,
          title: 'Najbolje ocijenjeni smještaji',
          subtitle: 'Rangirano po prosječnoj ocjeni gostiju',
        ),
        footer: _footer,
        build: (context) => [
          _summaryRow([
            ('Ocijenjenih smještaja', '${ranked.length}'),
            ('Ukupno smještaja', '${accommodations.length}'),
            (
              'Prosječna ocjena',
              ranked.isEmpty
                  ? '—'
                  : (ranked.map((a) => a.reviewScore).reduce((a, b) => a + b) /
                          ranked.length)
                      .toStringAsFixed(2)
            ),
          ]),
          pw.SizedBox(height: 22),
          if (top.isEmpty)
            _emptyNotice('Nijedan smještaj još nema ocjenu gostiju.')
          else
            _table(
              headers: const [
                'Rang',
                'Naziv',
                'Tip',
                'Grad, država',
                'Ocjena',
                'Cijena / noć',
              ],
              alignments: const [
                pw.Alignment.centerLeft,
                pw.Alignment.centerLeft,
                pw.Alignment.centerLeft,
                pw.Alignment.centerLeft,
                pw.Alignment.centerRight,
                pw.Alignment.centerRight,
              ],
              widths: const {
                0: pw.FixedColumnWidth(38),
                1: pw.FlexColumnWidth(3),
                2: pw.FlexColumnWidth(1.6),
                3: pw.FlexColumnWidth(2.6),
                4: pw.FixedColumnWidth(52),
                5: pw.FixedColumnWidth(78),
              },
              rows: [
                for (var i = 0; i < top.length; i++)
                  [
                    '${i + 1}.',
                    top[i].name,
                    top[i].typeOfAccommodation.label,
                    top[i].location.placeLabel,
                    top[i].reviewScore.toStringAsFixed(1),
                    _money.format(top[i].pricePerNight),
                  ],
              ],
            ),
        ],
      ),
    );

    return document.save();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Izvještaj 2 — Rezervacije po gradovima i državama
  // ═════════════════════════════════════════════════════════════════════════

  static Future<Uint8List> reservationsByCity(
    List<ReservationGET> reservations, {
    required DateTime from,
    required DateTime to,
  }) async {
    // Agregacija jednim prolazom (Upute 8.2 — agregaciju raditi jednim
    // upitom/prolazom, ne kroz više odvojenih).
    final byPlace = <String, ({String city, String country, int count, double revenue})>{};

    for (final reservation in reservations) {
      final location = reservation.accommodation?.location;
      final city = (location?.cityName.isNotEmpty ?? false)
          ? location!.cityName
          : 'Nepoznat grad';
      final country = (location?.countryName.isNotEmpty ?? false)
          ? location!.countryName
          : '—';
      final key = '$city|$country';

      final existing = byPlace[key];
      byPlace[key] = (
        city: city,
        country: country,
        count: (existing?.count ?? 0) + 1,
        revenue: (existing?.revenue ?? 0) + reservation.estimatedRevenue,
      );
    }

    final rows = byPlace.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final totalCount = rows.fold<int>(0, (sum, r) => sum + r.count);
    final totalRevenue = rows.fold<double>(0, (sum, r) => sum + r.revenue);

    final document = pw.Document(theme: await _theme());

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 44, 40, 48),
        header: (context) => _header(
          context,
          title: 'Rezervacije po gradovima i državama',
          subtitle: 'Period: ${_dateFormat.format(from)} – '
              '${_dateFormat.format(to)}',
        ),
        footer: _footer,
        build: (context) => [
          _summaryRow([
            ('Ukupno rezervacija', '$totalCount'),
            ('Gradova sa prometom', '${rows.length}'),
            ('Procijenjeni prihod', _money.format(totalRevenue)),
          ]),
          pw.SizedBox(height: 22),
          if (rows.isEmpty)
            _emptyNotice('U odabranom periodu nema evidentiranih rezervacija.')
          else ...[
            _table(
              headers: const [
                'Grad',
                'Država',
                'Rezervacija',
                'Udio',
                'Procijenjeni prihod',
              ],
              alignments: const [
                pw.Alignment.centerLeft,
                pw.Alignment.centerLeft,
                pw.Alignment.centerRight,
                pw.Alignment.centerRight,
                pw.Alignment.centerRight,
              ],
              widths: const {
                0: pw.FlexColumnWidth(2.4),
                1: pw.FlexColumnWidth(2.8),
                2: pw.FixedColumnWidth(76),
                3: pw.FixedColumnWidth(52),
                4: pw.FixedColumnWidth(104),
              },
              rows: [
                for (final row in rows)
                  [
                    row.city,
                    row.country,
                    '${row.count}',
                    totalCount == 0
                        ? '—'
                        : '${(row.count / totalCount * 100).toStringAsFixed(1)}%',
                    _money.format(row.revenue),
                  ],
              ],
              totals: [
                'UKUPNO',
                '',
                '$totalCount',
                '100%',
                _money.format(totalRevenue),
              ],
            ),
            pw.SizedBox(height: 18),
            _methodologyNote(),
          ],
        ],
      ),
    );

    return document.save();
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Zajednički elementi
  // ═════════════════════════════════════════════════════════════════════════

  static pw.Widget _header(
    pw.Context context, {
    required String title,
    required String subtitle,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _accent, width: 1.4)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'eBooking · Administratorski izvještaj',
                  style: pw.TextStyle(
                    fontSize: 8,
                    letterSpacing: 1.1,
                    color: _accent,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 17,
                    fontWeight: pw.FontWeight.bold,
                    color: _ink,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  subtitle,
                  style: const pw.TextStyle(fontSize: 9, color: _muted),
                ),
              ],
            ),
          ),
          pw.Text(
            'Generisano ${_dateTimeFormat.format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _rule, width: 0.6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'eBooking — seminarski rad, Razvoj softvera II',
            style: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
          pw.Text(
            'Stranica ${context.pageNumber} od ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryRow(List<(String, String)> stats) {
    return pw.Row(
      children: [
        for (final stat in stats)
          pw.Expanded(
            child: pw.Container(
              margin: const pw.EdgeInsets.only(right: 10),
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _rule, width: 0.6),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    stat.$1.toUpperCase(),
                    style: const pw.TextStyle(
                      fontSize: 7,
                      letterSpacing: 0.8,
                      color: _muted,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    stat.$2,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static pw.Widget _table({
    required List<String> headers,
    required List<List<String>> rows,
    required Map<int, pw.TableColumnWidth> widths,
    required List<pw.Alignment> alignments,
    List<String>? totals,
  }) {
    pw.Widget cell(String text, pw.Alignment alignment,
        {bool bold = false, bool muted = false}) {
      return pw.Container(
        alignment: alignment,
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: muted ? _muted : _ink,
          ),
        ),
      );
    }

    return pw.Table(
      columnWidths: widths,
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _ink, width: 0.8)),
          ),
          children: [
            for (var i = 0; i < headers.length; i++)
              pw.Container(
                alignment: alignments[i],
                padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                child: pw.Text(
                  headers[i].toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    letterSpacing: 0.7,
                    fontWeight: pw.FontWeight.bold,
                    color: _ink,
                  ),
                ),
              ),
          ],
        ),
        for (final row in rows)
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _rule, width: 0.5)),
            ),
            children: [
              for (var i = 0; i < row.length; i++)
                cell(row[i], alignments[i], muted: i != 0 && i != 1),
            ],
          ),
        if (totals != null)
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: _ink, width: 0.8)),
            ),
            children: [
              for (var i = 0; i < totals.length; i++)
                cell(totals[i], alignments[i], bold: true),
            ],
          ),
      ],
    );
  }

  static pw.Widget _emptyNotice(String message) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _rule, width: 0.6),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        message,
        style: const pw.TextStyle(fontSize: 10, color: _muted),
      ),
    );
  }

  /// Transparentnost umjesto tihe pretpostavke: izvještaj sam kaže kako je
  /// prihod izračunat i koje polje na backendu nedostaje.
  static pw.Widget _methodologyNote() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _rule, width: 0.6),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Metodologija',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: _ink,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Prihod je procijenjen kao broj noćenja × cijena po noćenju u '
            'trenutku generisanja izvještaja. Stvarno naplaćeni iznos nije '
            'dostupan jer ReservationGET ne sadrži polje sa iznosom plaćanja.',
            style: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ],
      ),
    );
  }
}
