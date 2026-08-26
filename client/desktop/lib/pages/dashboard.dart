import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

/// Pregled — četiri statistike, trend rezervacija, tabela nedavnih rezervacija.
///
/// Izmjene u odnosu na staru verziju:
///  - `Provider.of(..., listen: false)` u `build()` je značilo da se ekran
///    NIKAD ne osvježava kad podaci stignu. Sada `Consumer`.
///  - `calculateNumberOfRentsPerDay()` je bila lokalna funkcija definisana
///    UNUTAR `build()`-a, sa ugniježđenom petljom 30 × N rezervacija na svaki
///    rebuild. Premješteno u `AdminProvider.reservationsPerDay()`.
///  - `getHighestRent()`/`getLowestRent()` su rušili ekran na praznoj bazi.
///  - `barGroups` polje sa jednim hardkodiranim stubićem (`toY: 8`) je bilo
///    mrtav kod — nikad korišteno (Upute 8.1).
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.isLoading && !admin.hasData) {
          return const SectionScaffold(
            child: NLoading(label: 'Učitavanje podataka…'),
          );
        }

        if (admin.error != null && !admin.hasData) {
          return SectionScaffold(
            child: NErrorState(
              message: admin.error!,
              onRetry: admin.loadAll,
            ),
          );
        }

        return SectionScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NPageHeader(
                title: 'Pregled',
                subtitle: 'Stanje smještaja, korisnika i potražnje.',
                actions: [
                  OutlinedButton.icon(
                    onPressed: admin.isLoading ? null : admin.loadAll,
                    icon: Icon(PhosphorIcons.arrowsClockwise(), size: 14),
                    label: const Text('Osvježi'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.x6),
              _StatRow(admin: admin),
              const SizedBox(height: AppSpace.x6),
              _ReservationTrend(admin: admin),
              const SizedBox(height: AppSpace.x6),
              _RecentReservations(admin: admin),
            ],
          ),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  final AdminProvider admin;
  const _StatRow({required this.admin});

  @override
  Widget build(BuildContext context) {
    final highest = admin.highestRent;
    final lowest = admin.lowestRent;
    final money = NumberFormat.currency(locale: 'bs', symbol: 'KM ', decimalDigits: 0);

    // BUGFIX: ovaj Row je imao `crossAxisAlignment: CrossAxisAlignment.stretch`,
    // a nalazi se u Column-u unutar `SingleChildScrollView`-a — tamo je
    // visina NEOGRANIČENA. `stretch` u toj situaciji traži od djece da se
    // rastegnu na beskonačnu visinu, što obara layout i pokreće kaskadu
    // render grešaka svaki frame. `IntrinsicHeight` daje redu konkretnu
    // visinu (najviša kartica), pa se kartice i dalje poravnavaju.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatCard(
              kicker: 'Najviša cijena noćenja',
              value: highest == null ? '—' : money.format(highest.pricePerNight),
              caption: highest?.name ?? 'Nema unesenih smještaja',
            ),
          ),
          const SizedBox(width: AppSpace.x4),
          Expanded(
            child: _StatCard(
              kicker: 'Najniža cijena noćenja',
              value: lowest == null ? '—' : money.format(lowest.pricePerNight),
              caption: lowest?.name ?? 'Nema unesenih smještaja',
            ),
          ),
          const SizedBox(width: AppSpace.x4),
          Expanded(
            child: _StatCard(
              kicker: 'Registrovani korisnici',
              value: '${admin.profiles.length}',
              caption: '${admin.activeUserCount} aktivnih',
            ),
          ),
          const SizedBox(width: AppSpace.x4),
          Expanded(
            child: _StatCard(
              kicker: 'Smještaji',
              value: '${admin.accommodations.length}',
              caption: '${admin.activeAccommodationCount} aktivnih '
                  '· ${admin.availableCities.length} gradova',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String kicker;
  final String value;
  final String caption;

  const _StatCard({
    required this.kicker,
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          NKicker(kicker),
          const SizedBox(height: AppSpace.x2),
          Text(
            value,
            style: theme.textTheme.headlineSmall,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpace.x1),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ReservationTrend extends StatelessWidget {
  final AdminProvider admin;
  const _ReservationTrend({required this.admin});

  @override
  Widget build(BuildContext context) {
    final data = admin.reservationsPerDay(days: 30);
    final total = data.fold<num>(0, (sum, d) => sum + d.value);

    return NCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NKicker('Posljednjih 30 dana'),
          const SizedBox(height: AppSpace.x1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Zauzetost po danima',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                'Ukupno $total noćenja u periodu',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.x6),
          NBarChart(data: data, height: 150, showEveryLabel: false),
        ],
      ),
    );
  }
}

class _RecentReservations extends StatelessWidget {
  final AdminProvider admin;
  const _RecentReservations({required this.admin});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final now = DateTime.now();

    // Najnovije prvo (Upute 6: "najnoviji zapis mora biti prikazan na vrhu").
    final reservations = admin.reservations.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final visible = reservations.take(8).toList();

    return NCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.x4, AppSpace.x4, AppSpace.x4, AppSpace.x3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const NKicker('Nedavna aktivnost'),
                const SizedBox(height: AppSpace.x1),
                Text(
                  'Rezervacije',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          NTable(
            columns: const [
              NColumn('Smještaj', flex: 3),
              NColumn('Lokacija', flex: 2),
              NColumn('Termin', width: 200),
              NColumn('Gostiju', width: 80),
              NColumn('Status', width: 120),
            ],
            rowCount: visible.length,
            empty: const NEmptyState(
              message: 'Za odabrani period nema evidentiranih rezervacija.',
            ),
            cellsBuilder: (context, index) {
              final r = visible[index];
              final accommodation = r.accommodation;

              // Upute 7: status se prikazuje vizuelno, izveden iz termina.
              // NAPOMENA: `ReservationGET` nema `status` polje — backend još
              // nema state machine (Pending -> Confirmed -> Cancelled /
              // Completed). Do tada ovo je izvedeno iz datuma i tako je i
              // označeno. Prijavljeno kao nedostajuća backend funkcionalnost.
              final ({String label, NTagVariant variant}) status;
              if (r.endDate.isBefore(now)) {
                status = (label: 'Završeno', variant: NTagVariant.neutral);
              } else if (r.startDate.isAfter(now)) {
                status = (label: 'Predstoji', variant: NTagVariant.outline);
              } else {
                status = (label: 'U toku', variant: NTagVariant.accent);
              }

              return [
                Text(
                  accommodation?.name ?? 'Nepoznat smještaj',
                  overflow: TextOverflow.ellipsis,
                ),
                NMutedCell(accommodation?.location.placeLabel ?? '—'),
                NMutedCell(
                  '${dateFormat.format(r.startDate)} – '
                  '${dateFormat.format(r.endDate)}',
                ),
                NMutedCell('${r.numberOfGuests}'),
                NTag(status.label, variant: status.variant),
              ];
            },
          ),
        ],
      ),
    );
  }
}

// UKLONJENO (Upute 8.1 — mrtav kod):
//   - `DashboardApp` — omotač koji je samo vraćao `DashboardPage()`.
//     `main.dart` sada direktno gradi `AppShell`.
//   - `DashboardStat` — javna klasa korištena isključivo iz `buildStatCard`,
//     zamijenjena privatnim `_StatCard`-om.
//   - `barGroups` — polje sa jednim hardkodiranim stubićem (`toY: 8`) koje
//     nijedan widget nije čitao.
