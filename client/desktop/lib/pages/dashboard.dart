import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';
import 'package:ebooking_desktop/widgets/reservation_status_tag.dart';

/// Pregled — četiri statistike, trend rezervacija, tabela nedavnih rezervacija.
///
/// Koristi `Consumer` umjesto `Provider.of(..., listen: false)` da se ekran osvježi čim podaci
/// stignu; `reservationsPerDay()` živi u `AdminProvider` umjesto lokalno u `build()` da se
/// ugniježđena petlja 30 × N rezervacija ne ponavlja na svaki rebuild.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        if (admin.isLoading && !admin.hasData) {
          return const SectionScaffold(
            child: NLoading(label: 'Loading data…'),
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
                title: 'Dashboard',
                subtitle: 'Status of properties, users and demand.',
                actions: [
                  OutlinedButton.icon(
                    onPressed: admin.isLoading ? null : admin.loadAll,
                    icon: Icon(PhosphorIcons.arrowsClockwise(), size: 14),
                    label: const Text('Refresh'),
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
              kicker: 'Highest nightly rate',
              value: highest == null ? '—' : money.format(highest.pricePerNight),
              caption: highest?.name ?? 'No properties entered',
            ),
          ),
          const SizedBox(width: AppSpace.x4),
          Expanded(
            child: _StatCard(
              kicker: 'Lowest nightly rate',
              value: lowest == null ? '—' : money.format(lowest.pricePerNight),
              caption: lowest?.name ?? 'No properties entered',
            ),
          ),
          const SizedBox(width: AppSpace.x4),
          Expanded(
            child: _StatCard(
              kicker: 'Registered users',
              value: '${admin.userTotalCount}',
              caption: '${admin.userActiveCount} active',
            ),
          ),
          const SizedBox(width: AppSpace.x4),
          Expanded(
            child: _StatCard(
              kicker: 'Properties',
              value: '${admin.accommodations.length}',
              caption: '${admin.activeAccommodationCount} active '
                  '· ${admin.availableCities.length} cities',
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
          const NKicker('Last 30 days'),
          const SizedBox(height: AppSpace.x1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Occupancy by day',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                'Total $total nights in the period',
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
                const NKicker('Recent activity'),
                const SizedBox(height: AppSpace.x1),
                Text(
                  'Reservations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          NTable(
            columns: const [
              NColumn('Property', flex: 3),
              NColumn('Location', flex: 2),
              NColumn('Dates', width: 200),
              NColumn('Guests', width: 80),
              NColumn('Status', width: 120),
            ],
            rowCount: visible.length,
            empty: const NEmptyState(
              message: 'No reservations recorded for the selected period.',
            ),
            cellsBuilder: (context, index) {
              final r = visible[index];
              final accommodation = r.accommodation;

              final status = r.status;

              return [
                Text(
                  accommodation?.name ?? 'Unknown property',
                  overflow: TextOverflow.ellipsis,
                ),
                NMutedCell(accommodation?.location.placeLabel ?? '—'),
                NMutedCell(
                  '${dateFormat.format(r.startDate)} – '
                  '${dateFormat.format(r.endDate)}',
                ),
                NMutedCell('${r.numberOfGuests}'),
                status == null
                    ? const NMutedCell('—')
                    : NTag(status.label, variant: reservationTagVariant(status)),
              ];
            },
          ),
        ],
      ),
    );
  }
}

