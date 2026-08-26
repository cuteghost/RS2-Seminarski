import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/models/accomodation_model.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

/// Referentni podaci — tipovi smještaja i sadržaji (amenities).
///
/// VAŽNA NAPOMENA O OPSEGU (i zašto ovaj ekran nije pun CRUD):
///
/// Dizajn (`eBooking Admin.dc.html`, sekcija "Reference data") prikazuje tri
/// taba sa punim CRUD-om: Accommodation types, Statuses, Amenities.
/// Na backendu, međutim, NIJEDNO od ta tri nije zasebna tabela:
///
///   - `TypeOfAccommodation` je C# enum (`Models.Domain.TypesOfAccommodation`),
///     serijalizovan kao `int` u koloni.
///   - `Status` je `bool?` na `Accommodation`.
///   - Sadržaji (AC, balkon, terasa…) su 14 zasebnih `bool` kolona na
///     `AccommodationDetails`.
///
/// Dodavanje novog tipa ili sadržaja kroz UI zahtijeva izmjenu C# koda i
/// migraciju — što UI ne može i ne smije raditi. Zato je ovaj ekran
/// READ-ONLY pregled sa brojačima korištenosti, a nedostupne akcije su
/// prikazane kao disabled uz objašnjenje (Upute 6).
///
/// Da bi se ispunio Upute 2.2 ("CRUD forme za SVE referentne podatke"), ta
/// tri pojma moraju postati prave tabele na backendu. Detaljan prijedlog je
/// u izvještaju `REDESIGN-IZVJESTAJ.md`, sekcija "Nedostajuće backend
/// funkcionalnosti". Do tada su države i gradovi (ekran Lokacije) jedini
/// referentni podaci sa punim CRUD-om.
class ReferenceDataPage extends StatefulWidget {
  const ReferenceDataPage({super.key});

  @override
  State<ReferenceDataPage> createState() => _ReferenceDataPageState();
}

class _ReferenceDataPageState extends State<ReferenceDataPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        return SectionScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const NPageHeader(
                title: 'Referentni podaci',
                subtitle: 'Standardizovane vrijednosti koje dijele svi smještaji.',
              ),
              const SizedBox(height: AppSpace.x6),
              const _BackendNotice(),
              const SizedBox(height: AppSpace.x6),
              NTabs(
                labels: const ['Tipovi smještaja', 'Statusi', 'Sadržaji'],
                selected: _tab,
                onChanged: (index) => setState(() => _tab = index),
              ),
              const SizedBox(height: AppSpace.x4),
              NCard(
                padding: EdgeInsets.zero,
                clip: true,
                child: switch (_tab) {
                  0 => _TypesTable(admin: admin),
                  1 => _StatusesTable(admin: admin),
                  _ => _AmenitiesTable(admin: admin),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BackendNotice extends StatelessWidget {
  const _BackendNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        color: AppColors.accentTint.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        border: Border.all(color: AppColors.accentBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIcons.info(), size: 16, color: AppColors.accent),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Text(
              'Ove vrijednosti su trenutno definisane u kodu (enum i bool '
              'kolone), a ne u zasebnim tabelama, pa se ne mogu uređivati iz '
              'aplikacije. Pregled prikazuje koliko ih smještaja koristi. '
              'Države i gradovi imaju pun CRUD na ekranu „Lokacije".',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.accentText, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

/// Zajednička tabela: naziv + brojač korištenosti + disabled akcije.
class _ReferenceTable extends StatelessWidget {
  final String nameColumn;
  final List<({String name, int count})> rows;
  final String disabledReason;
  final String emptyMessage;

  const _ReferenceTable({
    required this.nameColumn,
    required this.rows,
    required this.disabledReason,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return NTable(
      columns: [
        NColumn(nameColumn, flex: 3),
        const NColumn('Koristi smještaja', width: 170, align: Alignment.centerRight),
        const NColumn('', width: 76, align: Alignment.centerRight),
      ],
      rowCount: rows.length,
      empty: NEmptyState(message: emptyMessage),
      cellsBuilder: (context, index) {
        final row = rows[index];
        return [
          Text(row.name, overflow: TextOverflow.ellipsis),
          NMutedCell('${row.count}'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              NIconAction(
                icon: PhosphorIcons.pencilSimple(),
                tooltip: 'Izmijeni',
                disabledReason: disabledReason,
                onPressed: null,
              ),
              NIconAction(
                icon: PhosphorIcons.trash(),
                tooltip: 'Obriši',
                color: AppColors.error,
                disabledReason: disabledReason,
                onPressed: null,
              ),
            ],
          ),
        ];
      },
    );
  }
}

class _TypesTable extends StatelessWidget {
  final AdminProvider admin;
  const _TypesTable({required this.admin});

  @override
  Widget build(BuildContext context) {
    final rows = TypesOfAccommodation.values
        .map((type) => (
              name: type.label,
              count: admin.accommodations
                  .where((a) => a.typeOfAccommodation == type)
                  .length,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return _ReferenceTable(
      nameColumn: 'Tip smještaja',
      rows: rows,
      emptyMessage: 'Nema definisanih tipova smještaja.',
      disabledReason: 'Tipovi smještaja su C# enum '
          '(TypesOfAccommodation), a ne tabela — mijenjaju se u kodu '
          'uz migraciju baze.',
    );
  }
}

class _StatusesTable extends StatelessWidget {
  final AdminProvider admin;
  const _StatusesTable({required this.admin});

  @override
  Widget build(BuildContext context) {
    final active = admin.accommodations.where((a) => a.status).length;
    final inactive = admin.accommodations.length - active;

    return _ReferenceTable(
      nameColumn: 'Status',
      rows: [(name: 'Aktivan', count: active), (name: 'Neaktivan', count: inactive)],
      emptyMessage: 'Nema podataka o statusima.',
      disabledReason: 'Status je bool kolona na entitetu Accommodation, '
          'a ne referentna tabela. Backend još nema state machine '
          '(Pending → Confirmed → Cancelled / Completed).',
    );
  }
}

class _AmenitiesTable extends StatelessWidget {
  final AdminProvider admin;
  const _AmenitiesTable({required this.admin});

  /// Mora ostati usklađeno sa `AccommodationDetails.amenityLabels`.
  /// (Idealno bi ovo dolazilo sa servera — vidi napomenu na vrhu fajla.)
  static const _allAmenityLabels = <String>[
    'Klima',
    'Balkon',
    'Privatno kupatilo',
    'Terasa',
    'Kuhinja',
    'Privatni bazen',
    'Aparat za kafu',
    'Pogled',
    'Pogled na more',
    'Veš mašina',
    'Spa kada',
    'Kada',
    'Zvučna izolacija',
    'Doručak',
  ];

  @override
  Widget build(BuildContext context) {
    // Brojanje ide jednim prolazom kroz smještaje umjesto N prolaza po sadržaju.
    final counts = <String, int>{};
    for (final accommodation in admin.accommodations) {
      for (final label in accommodation.accommodationDetails.amenityLabels) {
        counts[label] = (counts[label] ?? 0) + 1;
      }
    }

    // Sadržaji koji postoje kao kolona, ali ih nijedan smještaj nema,
    // moraju se ipak prikazati — inače pregled laže o tome šta sistem podržava.
    for (final label in _allAmenityLabels) {
      counts.putIfAbsent(label, () => 0);
    }

    final rows = counts.entries
        .map((e) => (name: e.key, count: e.value))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return _ReferenceTable(
      nameColumn: 'Sadržaj',
      rows: rows,
      emptyMessage: 'Nema definisanih sadržaja.',
      disabledReason: 'Sadržaji su 14 zasebnih bool kolona na '
          'AccommodationDetails, a ne referentna tabela — dodavanje novog '
          'zahtijeva izmjenu modela i migraciju.',
    );
  }
}
