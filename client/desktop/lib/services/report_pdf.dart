import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:ebooking_desktop/models/accomodation_model.dart';

/// Generator PDF izvještaja.
///
/// Fontovi: koristi se Inter iz `assets/fonts/`. Ugrađeni Helvetica koristi
/// WinAnsi enkodiranje koje NE pokriva č/ć/š/ž/đ, pa bi nazivi poput
/// "Baščaršija" izašli izlomljeni. Ako font iz nekog razloga nije dostupan,
/// pada se na ugrađeni — izvještaj se i dalje generiše.
class ReportPdf {
  ReportPdf._();

  static pw.ThemeData? _cachedTheme;

  static final _dateFmt = DateFormat('dd.MM.yyyy.');
  static final _dateTimeFmt = DateFormat('dd.MM.yyyy. HH:mm');
  static final _moneyFmt =
      NumberFormat.currency(locale: 'bs', symbol: 'KM', decimalDigits: 2);

  /// Učitava i kešira temu.
  static Future<pw.ThemeData?> _theme() async {
    if (_cachedTheme != null) return _cachedTheme;
    try {
      final regular = pw.Font.ttf(
          await rootBundle.load('assets/fonts/Inter-Regular.ttf'));
      final medium = pw.Font.ttf(
          await rootBundle.load('assets/fonts/Inter-Medium.ttf'));
      final bold =
          pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-SemiBold.ttf'));
      _cachedTheme = pw.ThemeData.withFont(
        base: regular,
        bold: bold,
        italic: regular,
        boldItalic: medium,
      );
    } catch (_) {
      // Font nije u assetima — nastavljamo sa ugrađenim (bez naših dijakritika).
      _cachedTheme = null;
    }
    return _cachedTheme;
  }

  static const _accent = PdfColor.fromInt(0xFF5D5294);
  static const _muted = PdfColor.fromInt(0xFF75798C);
  static const _rule = PdfColor.fromInt(0xFFCFD3E5);

  // ── Izvještaj 1: Najbolje ocijenjeni smještaji ───────────────────────────

  static Future<Uint8List> topRatedProperties({
    required List<AccommodationGET> accommodations,
    required String generatedBy,
  }) async {
    final rows = [...accommodations]
      ..sort((a, b) => b.reviewScore.compareTo(a.reviewScore));

    final doc = pw.Document(theme: await _theme());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 44),
        header: (context) => _header(
          title: 'Top-rated properties',
          subtitle: 'Ranked by average guest rating',
        ),
        footer: (context) => _footer(context, generatedBy),
        build: (context) => [
          _summary([
            ('Total properties', '${accommodations.length}'),
            (
              'With at least one rating',
              '${accommodations.where((a) => a.reviewScore > 0).length}'
            ),
            (
              'Average rating',
              accommodations.isEmpty
                  ? '—'
                  : (accommodations
                              .map((a) => a.reviewScore)
                              .fold<double>(0, (s, v) => s + v) /
                          accommodations.length)
                      .toStringAsFixed(2)
            ),
          ]),
          pw.SizedBox(height: 18),
          if (rows.isEmpty)
            _emptyNote('No properties entered in the database.')
          else
            _table(
              headers: const [
                '#',
                'Property',
                'Type',
                'City, country',
                'Price / night',
                'Rating'
              ],
              widths: const {
                0: pw.FixedColumnWidth(26),
                1: pw.FlexColumnWidth(3.2),
                2: pw.FlexColumnWidth(1.5),
                3: pw.FlexColumnWidth(2.6),
                4: pw.FixedColumnWidth(78),
                5: pw.FixedColumnWidth(50),
              },
              rows: [
                for (var i = 0; i < rows.length; i++)
                  [
                    '${i + 1}',
                    rows[i].name.isEmpty ? 'No name' : rows[i].name,
                    rows[i].typeLabel,
                    rows[i].location.placeLabel,
                    _moneyFmt.format(rows[i].pricePerNight),
                    rows[i].reviewScore == 0
                        ? '—'
                        : rows[i].reviewScore.toStringAsFixed(1),
                  ],
              ],
              rightAlignFrom: 4,
            ),
        ],
      ),
    );

    return doc.save();
  }

  // ── Izvještaj 2: Rezervacije i prihod po gradu ───────────────────────────

  static Future<Uint8List> reservationsByCity({
    required List<({String city, String country, int count, double revenue})>
        data,
    required DateTime windowStart,
    required DateTime windowEnd,
    required String generatedBy,
  }) async {
    final totalCount = data.fold<int>(0, (s, r) => s + r.count);
    final totalRevenue = data.fold<double>(0, (s, r) => s + r.revenue);

    final doc = pw.Document(theme: await _theme());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 44),
        header: (context) => _header(
          title: 'Reservations by city and country',
          subtitle: 'Period: ${_dateFmt.format(windowStart)} '
              '– ${_dateFmt.format(windowEnd)}',
        ),
        footer: (context) => _footer(context, generatedBy),
        build: (context) => [
          _summary([
            ('Total reservations', '$totalCount'),
            ('Total revenue', _moneyFmt.format(totalRevenue)),
            ('Number of cities', '${data.length}'),
          ]),
          pw.SizedBox(height: 18),
          if (data.isEmpty)
            _emptyNote('No reservations in the observed period.')
          else ...[
            _table(
              headers: const [
                'City',
                'Country',
                'Reservations',
                'Share',
                'Revenue'
              ],
              widths: const {
                0: pw.FlexColumnWidth(2.4),
                1: pw.FlexColumnWidth(2.8),
                2: pw.FixedColumnWidth(74),
                3: pw.FixedColumnWidth(48),
                4: pw.FixedColumnWidth(88),
              },
              rows: [
                for (final r in data)
                  [
                    r.city,
                    r.country,
                    '${r.count}',
                    totalCount == 0
                        ? '—'
                        : '${(r.count / totalCount * 100).toStringAsFixed(1)}%',
                    _moneyFmt.format(r.revenue),
                  ],
              ],
              rightAlignFrom: 2,
              totalRow: [
                'TOTAL',
                '',
                '$totalCount',
                '100%',
                _moneyFmt.format(totalRevenue),
              ],
            ),
            pw.SizedBox(height: 14),
            pw.Text(
              'Revenue is the total reservation amount locked in by the server at the '
              'time of booking, so a later change to a property\'s price does not change '
              'previously recorded amounts.',
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
          ],
        ],
      ),
    );

    return doc.save();
  }

  // ── Zajednički gradivni blokovi ──────────────────────────────────────────

  static pw.Widget _header({required String title, required String subtitle}) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 18),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _rule, width: 0.8)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'eBooking',
                style: pw.TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.4,
                  color: _accent,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(title, style: pw.TextStyle(fontSize: 17)),
              pw.SizedBox(height: 2),
              pw.Text(subtitle,
                  style: const pw.TextStyle(fontSize: 9, color: _muted)),
            ],
          ),
          pw.Text(
            _dateTimeFmt.format(DateTime.now()),
            style: const pw.TextStyle(fontSize: 8.5, color: _muted),
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer(pw.Context context, String generatedBy) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 14),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _rule, width: 0.6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by: $generatedBy',
            style: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
          pw.Text(
            'Page ${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ],
      ),
    );
  }

  static pw.Widget _summary(List<(String, String)> items) {
    return pw.Row(
      children: [
        for (final item in items)
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
                    item.$1.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 7,
                      letterSpacing: 0.8,
                      color: _accent,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(item.$2, style: pw.TextStyle(fontSize: 14)),
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
    int rightAlignFrom = 999,
    List<String>? totalRow,
  }) {
    pw.Widget cell(String text, int col, {bool header = false, bool total = false}) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        alignment: col >= rightAlignFrom
            ? pw.Alignment.centerRight
            : pw.Alignment.centerLeft,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: header ? 7.5 : 9,
            letterSpacing: header ? 0.7 : 0,
            color: header ? _muted : PdfColors.black,
            fontWeight:
                (header || total) ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );
    }

    return pw.Table(
      columnWidths: widths,
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _rule, width: 0.4),
      ),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _rule, width: 0.8)),
          ),
          children: [
            for (var i = 0; i < headers.length; i++)
              cell(headers[i].toUpperCase(), i, header: true),
          ],
        ),
        for (final row in rows)
          pw.TableRow(children: [
            for (var i = 0; i < row.length; i++) cell(row[i], i),
          ]),
        if (totalRow != null)
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: _rule, width: 0.8)),
            ),
            children: [
              for (var i = 0; i < totalRow.length; i++)
                cell(totalRow[i], i, total: true),
            ],
          ),
      ],
    );
  }

  static pw.Widget _emptyNote(String message) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 30),
      alignment: pw.Alignment.center,
      child: pw.Text(
        message,
        style: const pw.TextStyle(fontSize: 10, color: _muted),
      ),
    );
  }
}
