import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/models/accomodation_model.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

/// Smještaji — tabela sa pretragom i tri filtera, plus detaljni prikaz.
///
/// Izmjene u odnosu na staru verziju:
///  - Bio je `GridView` sa `crossAxisCount: 6` — šest kartica po redu bez
///    obzira na širinu prozora, pa je na manjem ekranu sadržaj bio nečitljiv.
///    Dizajn traži tabelu; tabela je i pravi izbor za administratorski pregled.
///  - `Image(image: FileImage(accommodation.images.images[0]!))` je rušio
///    ekran za svaki smještaj bez slike (`Null check operator used on a null
///    value`) i čitao je fajl koji je model prethodno zapisao na disk.
///  - Dugme za brisanje je imalo prazan `onPressed` sa komentarom
///    "Handle directions action" (copy-paste ostatak) — Upute 3.4 traže
///    uklanjanje kontrola za koje ne postoji implementirana funkcionalnost.
///    Sada je dugme prisutno ali DISABLED sa objašnjenjem, jer backend
///    nema `DELETE /api/Accommodation/{id}`.
///  - Nije bilo nijednog parametra za pretragu (Upute 2.2 to izričito traže).
class ManagePropertiesPage extends StatefulWidget {
  const ManagePropertiesPage({super.key});

  @override
  State<ManagePropertiesPage> createState() => _ManagePropertiesPageState();
}

class _ManagePropertiesPageState extends State<ManagePropertiesPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sekcije se ruše i ponovo grade pri prebacivanju kroz sidebar, a upit
    // živi u provideru — bez ovoga bi polje izgledalo prazno dok je tabela
    // i dalje filtrirana.
    _searchController.text = context.read<AdminProvider>().propertyQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.isLoading && admin.accommodations.isEmpty) {
          return const SectionScaffold(
            child: NLoading(label: 'Učitavanje smještaja…'),
          );
        }

        final items = admin.filteredAccommodations;

        return SectionScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NPageHeader(
                title: 'Smještaji',
                subtitle: '${admin.accommodations.length} smještaja '
                    'u ${admin.availableCities.length} gradova.',
                actions: [
                  OutlinedButton.icon(
                    onPressed: admin.isLoading ? null : admin.getAccommodations,
                    icon: Icon(PhosphorIcons.arrowsClockwise(), size: 14),
                    label: const Text('Osvježi'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.x6),
              _Filters(admin: admin, controller: _searchController),
              const SizedBox(height: AppSpace.x4),
              _ResultCount(shown: items.length, total: admin.accommodations.length),
              const SizedBox(height: AppSpace.x3),
              NCard(
                padding: EdgeInsets.zero,
                clip: true,
                child: _PropertyTable(items: items),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Filters extends StatelessWidget {
  final AdminProvider admin;
  final TextEditingController controller;

  const _Filters({required this.admin, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: NSearchField(
            controller: controller,
            hint: 'Pretraga po nazivu, adresi ili gradu',
            onChanged: admin.setPropertyQuery,
          ),
        ),
        const SizedBox(width: AppSpace.x3),

        // Upute 6: padajuće liste se pune podacima iz baze. Lista gradova se
        // izvodi iz učitanih smještaja, nije hardkodirana.
        NDropdown<String?>(
          width: 170,
          value: admin.propertyCityFilter,
          hint: 'Svi gradovi',
          onChanged: admin.setPropertyCityFilter,
          items: [
            const DropdownMenuItem<String?>(value: null, child: Text('Svi gradovi')),
            for (final city in admin.availableCities)
              DropdownMenuItem<String?>(value: city, child: Text(city)),
          ],
        ),
        const SizedBox(width: AppSpace.x3),

        NDropdown<TypesOfAccommodation?>(
          width: 170,
          value: admin.propertyTypeFilter,
          hint: 'Svi tipovi',
          onChanged: admin.setPropertyTypeFilter,
          items: [
            const DropdownMenuItem<TypesOfAccommodation?>(
                value: null, child: Text('Svi tipovi')),
            for (final type in TypesOfAccommodation.values)
              DropdownMenuItem<TypesOfAccommodation?>(
                  value: type, child: Text(type.label)),
          ],
        ),
        const SizedBox(width: AppSpace.x3),

        NDropdown<bool?>(
          width: 150,
          value: admin.propertyStatusFilter,
          hint: 'Svi statusi',
          onChanged: admin.setPropertyStatusFilter,
          items: const [
            DropdownMenuItem<bool?>(value: null, child: Text('Svi statusi')),
            DropdownMenuItem<bool?>(value: true, child: Text('Aktivan')),
            DropdownMenuItem<bool?>(value: false, child: Text('Neaktivan')),
          ],
        ),
      ],
    );
  }
}

class _ResultCount extends StatelessWidget {
  final int shown;
  final int total;

  const _ResultCount({required this.shown, required this.total});

  @override
  Widget build(BuildContext context) {
    if (shown == total) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Prikazano $total zapisa',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Prikazano $shown od $total zapisa (filtrirano)',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _PropertyTable extends StatelessWidget {
  final List<AccommodationGET> items;

  const _PropertyTable({required this.items});

  @override
  Widget build(BuildContext context) {
    final money =
        NumberFormat.currency(locale: 'bs', symbol: 'KM ', decimalDigits: 0);

    return NTable(
      columns: const [
        // Upute 6: "Na svim relevantnim tabelarnim i list prikazima, za
        // entitete koji imaju sliku, uz naziv entiteta obavezno je prikazati
        // i odgovarajuću sliku."
        NColumn('', width: 52),
        NColumn('Naziv', flex: 3),
        NColumn('Tip', flex: 2),
        NColumn('Grad, država', flex: 3),
        NColumn('Cijena / noć', width: 120, align: Alignment.centerRight),
        NColumn('Ocjena', width: 90, align: Alignment.centerRight),
        NColumn('Status', width: 120),
        NColumn('', width: 76, align: Alignment.centerRight),
      ],
      rowCount: items.length,
      empty: const NEmptyState(
        message: 'Nijedan smještaj ne odgovara zadatim kriterijima pretrage.',
      ),
      onRowTap: (index) => _openDetails(context, items[index]),
      cellsBuilder: (context, index) {
        final item = items[index];
        return [
          _Thumbnail(images: item.images),
          Text(item.name, overflow: TextOverflow.ellipsis),
          NMutedCell(item.typeOfAccommodation.label),
          NMutedCell(item.location.placeLabel),
          Text(money.format(item.pricePerNight)),
          _Rating(score: item.reviewScore),
          NStatusTag(active: item.status),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              NIconAction(
                icon: PhosphorIcons.eye(),
                tooltip: 'Detalji smještaja',
                onPressed: () => _openDetails(context, item),
              ),
              // Upute 6: nedostupna akcija = disabled + objašnjenje razloga.
              NIconAction(
                icon: PhosphorIcons.trash(),
                tooltip: 'Obriši smještaj',
                disabledReason:
                    'Brisanje smještaja još nije dostupno — backend nema '
                    'DELETE /api/Accommodation endpoint.',
                onPressed: null,
              ),
            ],
          ),
        ];
      },
    );
  }

  void _openDetails(BuildContext context, AccommodationGET item) {
    showDialog<void>(
      context: context,
      barrierColor: AppColors.neutral900.withValues(alpha: 0.5),
      builder: (_) => _PropertyDetailsDialog(item: item),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final AccommodationImages images;

  const _Thumbnail({required this.images});

  @override
  Widget build(BuildContext context) {
    final bytes = images.first;

    return Container(
      width: 40,
      height: 30,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.neutral900,
        borderRadius: BorderRadius.circular(AppColors.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: bytes == null
          ? Icon(PhosphorIcons.image(), size: 14, color: AppColors.textTertiary)
          : Image.memory(
              bytes,
              fit: BoxFit.cover,
              // Ako je bajtova ali nisu validna slika, ne rušimo tabelu.
              errorBuilder: (_, __, ___) => Icon(
                PhosphorIcons.imageBroken(),
                size: 14,
                color: AppColors.textTertiary,
              ),
            ),
    );
  }
}

class _Rating extends StatelessWidget {
  final double score;
  const _Rating({required this.score});

  @override
  Widget build(BuildContext context) {
    if (score <= 0) return const NMutedCell('—');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(score.toStringAsFixed(1)),
        const SizedBox(width: 4),
        Icon(PhosphorIcons.star(PhosphorIconsStyle.fill),
            size: 11, color: AppColors.accent),
      ],
    );
  }
}

/// Master–detail: red tabele otvara detalje smještaja.
class _PropertyDetailsDialog extends StatelessWidget {
  final AccommodationGET item;

  const _PropertyDetailsDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final money =
        NumberFormat.currency(locale: 'bs', symbol: 'KM ', decimalDigits: 2);
    final amenities = item.accommodationDetails.amenityLabels;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              NDialogHeader(
                title: item.name,
                subtitle: item.location.address.isEmpty
                    ? item.location.placeLabel
                    : '${item.location.address} · ${item.location.placeLabel}',
              ),
              const SizedBox(height: AppSpace.x4),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Upute 6: slike ne smiju zauzimati više od 50% forme —
                      // traka od 120px u dijalogu visokom do 640px.
                      if (!item.images.isEmpty) _ImageStrip(images: item.images),
                      if (!item.images.isEmpty)
                        const SizedBox(height: AppSpace.x6),

                      Row(
                        children: [
                          NStatusTag(active: item.status),
                          const SizedBox(width: AppSpace.x2),
                          NTag(item.typeOfAccommodation.label),
                        ],
                      ),
                      const SizedBox(height: AppSpace.x6),

                      // Upute 6: dvije kolone — lijevo nazivi polja, desno
                      // vrijednosti (eksplicitna preporuka iz Slike 1).
                      _DetailRow(
                        label: 'Cijena po noćenju',
                        value: money.format(item.pricePerNight),
                      ),
                      _DetailRow(
                        label: 'Prosječna ocjena',
                        value: item.reviewScore <= 0
                            ? 'Još nema ocjena'
                            : item.reviewScore.toStringAsFixed(1),
                      ),
                      _DetailRow(
                        label: 'Broj kreveta',
                        value: '${item.accommodationDetails.numberOfBeds}',
                      ),
                      _DetailRow(
                        label: 'Koordinate',
                        value: '${item.location.latitude.toStringAsFixed(5)}, '
                            '${item.location.longitude.toStringAsFixed(5)}',
                      ),

                      if (item.description.isNotEmpty) ...[
                        const SizedBox(height: AppSpace.x6),
                        const NKicker('Opis'),
                        const SizedBox(height: AppSpace.x2),
                        Text(item.description, style: theme.textTheme.bodyMedium),
                      ],

                      if (amenities.isNotEmpty) ...[
                        const SizedBox(height: AppSpace.x6),
                        const NKicker('Sadržaji'),
                        const SizedBox(height: AppSpace.x3),
                        Wrap(
                          spacing: AppSpace.x2,
                          runSpacing: AppSpace.x2,
                          children: [for (final a in amenities) NTag(a)],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.x6),
              Align(
                alignment: Alignment.centerRight,
                // Upute 6: obavezno dugme za povratak/zatvaranje.
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Nazad'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageStrip extends StatelessWidget {
  final AccommodationImages images;

  const _ImageStrip({required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.images.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpace.x2),
        itemBuilder: (context, index) => ClipRRect(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          child: Image.memory(
            images.images[index],
            width: 170,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 170,
              color: AppColors.neutral900,
              alignment: Alignment.center,
              child: Icon(PhosphorIcons.imageBroken(),
                  size: 18, color: AppColors.textTertiary),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.x3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
