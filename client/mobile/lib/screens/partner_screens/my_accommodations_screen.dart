import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/providers/reservation_provider.dart';
import 'package:ebooking/screens/partner_screens/accommodation_screen.dart';
import 'package:ebooking/screens/partner_screens/add_accommodation_screen.dart';
import 'package:ebooking/widgets/custom_partner_bottom_navigation_bar.dart';
import 'package:ebooking/widgets/partner_earnings_card.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/widgets/accommodation_container.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';
import 'package:ebooking/utils/rating.dart';

class _Dashboard {
  const _Dashboard({
    required this.accommodations,
    required this.reservations,
    this.earningsError,
  });

  final List<AccommodationGET> accommodations;
  final List<ReservationGET> reservations;
  final String? earningsError;
}

class MyAccommodationsScreen extends StatefulWidget {
  const MyAccommodationsScreen({super.key});

  @override
  State<MyAccommodationsScreen> createState() => _MyAccommodationsScreenState();
}

class _MyAccommodationsScreenState extends State<MyAccommodationsScreen> {
  late Future<_Dashboard> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Dashboard> _load() {
    final accommodationProvider = Provider.of<AccommodationProvider>(
      context,
      listen: false,
    );
    final reservationProvider = Provider.of<ReservationProvider>(
      context,
      listen: false,
    );

    final bookings = reservationProvider
        .fetchPartnerReservations()
        .then<(List<ReservationGET>, String?)>((items) => (items, null))
        .onError<ApiException>(
          (error, _) => (const <ReservationGET>[], error.message),
        );

    return accommodationProvider.getMyAccommodations().then((
      accommodations,
    ) async {
      final (reservations, earningsError) = await bookings;
      return _Dashboard(
        accommodations: accommodations,
        reservations: reservations,
        earningsError: earningsError,
      );
    });
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _publish(AccommodationGET accommodation) async {
    final patch = AccommodationPATCH(
      id: accommodation.id,
      status: true,
      name: accommodation.name,
      accommodationTypeId: accommodation.accommodationTypeId,
      pricePerNight: accommodation.pricePerNight,
      description: accommodation.description,
      accommodationDetails: accommodation.accommodationDetails,
      images: null,
    );
    String? failure;
    try {
      await Provider.of<AccommodationProvider>(
        context,
        listen: false,
      ).updateAccommodation(patch);
    } on ApiException catch (e) {
      failure = e.message;
    }
    if (!mounted) return;
    if (failure == null) {
      _reload();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<_Dashboard>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // ApiException.toString() is the server's own message.
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '${snapshot.error}',
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final dashboard = snapshot.data;
            final accommodations =
                dashboard?.accommodations ?? const <AccommodationGET>[];
            final liveCount = accommodations.where((a) => a.status).length;
            final rated = accommodations
                .where((a) => a.reviewScore > 0)
                .toList();
            final averageRating = rated.isEmpty
                ? null
                : rated.map((a) => a.reviewScore).reduce((a, b) => a + b) /
                      rated.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your properties',
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              averageRating == null
                                  ? 'No ratings yet'
                                  : 'Average rating ${formatRating(averageRating)}',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddAccommodationScreen(),
                            ),
                          );
                          _reload();
                        },
                        icon: Icon(PhosphorIcons.plus(), size: 14),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: 'LISTINGS',
                              value: '${accommodations.length}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              label: 'ACTIVE',
                              value: '$liveCount',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              label: 'INACTIVE',
                              value: '${accommodations.length - liveCount}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      PartnerEarningsCard(
                        reservations:
                            dashboard?.reservations ??
                            const <ReservationGET>[],
                        errorMessage: dashboard?.earningsError,
                      ),
                      const SizedBox(height: 20),
                      Text('YOUR PROPERTIES', style: textTheme.labelSmall),
                      const SizedBox(height: 10),
                      if (accommodations.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 26,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PhosphorIcons.houseLine(),
                                size: 32,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No properties yet',
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Add your first listing to start taking bookings.',
                                style: textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        for (final accommodation in accommodations) ...[
                          AccommodationContainer(
                            imageUrl: accommodation.firstImageUrl,
                            propertyName: accommodation.name,
                            address: accommodation.location.address,
                            reviews: accommodation.reviews.length,
                            isAvailable: accommodation.status,
                            reviewScore: accommodation.reviewScore,
                            price: accommodation.pricePerNight.toStringAsFixed(
                              0,
                            ),
                            numberOfBeds:
                                accommodation.accommodationDetails.numberOfBeds,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AccommodationScreen(
                                    accommodation: accommodation,
                                  ),
                                ),
                              );
                              _reload();
                            },
                            onPublish: () => _publish(accommodation),
                          ),
                          const SizedBox(height: 14),
                        ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const CustomPartnerBottomNavigationBar(
        currentIndex: 0,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelSmall),
          const SizedBox(height: 5),
          Text(value, style: textTheme.titleLarge),
        ],
      ),
    );
  }
}
