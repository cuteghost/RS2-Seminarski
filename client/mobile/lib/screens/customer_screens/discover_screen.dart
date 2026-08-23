import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/providers/reservation_provider.dart';
import 'package:ebooking/screens/customer_screens/maps_screen.dart';
import 'package:ebooking/screens/customer_screens/search_screen.dart';
import 'package:ebooking/screens/customer_screens/suggestions_screen.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/accommodation_details_screen.dart';
import 'package:ebooking/screens/customer_screens/history_screen.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class DiscoverPropertiesPage extends StatefulWidget {
  const DiscoverPropertiesPage({super.key});

  @override
  DiscoverPropertiesPageState createState() => DiscoverPropertiesPageState();
}

class DiscoverPropertiesPageState extends State<DiscoverPropertiesPage> {
  Position? _currentPosition;
  List<AccommodationGET>? _nearbyAccommodations;
  ReservationGET? _nextTrip;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) {
      _getNearbyAccommodations().then((value) {
        if (!mounted) return;
        setState(() => _nearbyAccommodations = value);
      });
    });
    _getNextTrip().then((value) {
      if (!mounted) return;
      setState(() => _nextTrip = value);
    });
  }

  Future<void> _getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    if (mounted) {
      setState(() => _currentPosition = position);
    }
  }

  Future<List<AccommodationGET>> _getNearbyAccommodations() async {
    if (_currentPosition == null) return [];
    return Provider.of<AccommodationProvider>(context, listen: false)
        .fetchNearbyAccommodations(
            _currentPosition!.latitude, _currentPosition!.longitude);
  }

  // The next upcoming (not-yet-started) reservation, soonest first. Reuses
  // the same provider call the History screen already makes -- no new
  // backend endpoint, just showing data the app already fetches elsewhere.
  // Swallow errors here (e.g. no reservations yet for a new account) --
  // this is a "nice to have" section on the home screen, not something
  // that should surface as an unhandled exception if it 404s or is empty.
  Future<ReservationGET?> _getNextTrip() async {
    try {
      final reservations =
          await Provider.of<ReservationProvider>(context, listen: false)
              .fetchMyReservations();
      final upcoming = reservations
          .where((r) => r.startDate.isAfter(DateTime.now()))
          .toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
      return upcoming.isEmpty ? null : upcoming.first;
    } catch (_) {
      return null;
    }
  }

  double? _distanceKm(AccommodationGET accommodation) {
    if (_currentPosition == null) return null;
    final meters = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      accommodation.location.latitude,
      accommodation.location.longitude,
    );
    return meters / 1000;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentPosition == null
                                ? 'Locating…'
                                : 'Nearby',
                            style: textTheme.bodySmall,
                          ),
                          Text(
                            '$greeting, ${profile.displayName}',
                            style: textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: AppColors.accentTint,
                      child: Icon(PhosphorIcons.user(),
                          color: AppColors.accentLink, size: 19),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const SearchAccommodationsScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppColors.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.magnifyingGlass(),
                            color: AppColors.accent, size: 19),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Where to?', style: textTheme.bodyMedium),
                              Text('Anywhere · Any week · 2 guests',
                                  style: textTheme.bodySmall),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(PhosphorIcons.mapTrifold(),
                              size: 18, color: AppColors.textSecondary),
                          tooltip: 'Map view',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MapPage()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Near you', style: textTheme.titleLarge),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SuggestionsScreen(customerId: profile.id),
                          ),
                        );
                      },
                      child: Text('See all',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: AppColors.accentLink)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 238,
                child: _nearbyAccommodations == null
                    ? const Center(child: CircularProgressIndicator())
                    : _nearbyAccommodations!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'No accommodations nearby yet. Try widening your search.',
                              style: textTheme.bodySmall,
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _nearbyAccommodations!.length,
                            itemBuilder: (context, index) {
                              final accommodation =
                                  _nearbyAccommodations![index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: NearbyPropertyCard(
                                  accommodation: accommodation,
                                  distanceKm: _distanceKm(accommodation),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AccommodationDetailsScreen(
                                                accommodation: accommodation),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your next trip', style: textTheme.titleLarge),
                    if (_nextTrip != null)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const ReservationHistoryPage()),
                          );
                        },
                        child: Text('All trips',
                            style: textTheme.bodyMedium
                                ?.copyWith(color: AppColors.accentLink)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _nextTrip == null
                    ? Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(AppColors.radiusMd),
                        ),
                        child: Text(
                          'No upcoming trips yet. Once you book a stay, it shows up here.',
                          style: textTheme.bodySmall,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(AppColors.radiusMd),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                _nextTrip!.thumbnail,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nextTrip!.accommodation?.name ?? '',
                                    style: textTheme.titleMedium,
                                  ),
                                  Text(
                                    '${DateFormat('d–').format(_nextTrip!.startDate)}${DateFormat('d MMM').format(_nextTrip!.endDate)} · '
                                    '${_nextTrip!.endDate.difference(_nextTrip!.startDate).inDays} nights',
                                    style: textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 11, vertical: 8),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AccommodationDetailsScreen(
                                            accommodation:
                                                _nextTrip!.accommodation!),
                                  ),
                                );
                              },
                              child: const Text('Details'),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }
}


class NearbyPropertyCard extends StatelessWidget {
  final AccommodationGET accommodation;
  final double? distanceKm;
  final VoidCallback onTap;

  const NearbyPropertyCard({
    super.key,
    required this.accommodation,
    required this.distanceKm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final image = accommodation.images.images.isNotEmpty
        ? accommodation.images.images.first
        : null;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 214,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  child: image != null
                      ? Image.file(
                          image,
                          height: 148,
                          width: 214,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 148,
                          width: 214,
                          color: AppColors.surface,
                          alignment: Alignment.center,
                          child: Icon(PhosphorIcons.image(),
                              color: AppColors.textTertiary),
                        ),
                ),
                if (accommodation.reviewScore > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.bg.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIcons.star(PhosphorIconsStyle.fill),
                              size: 11, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(accommodation.reviewScore.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 9),
            Text(accommodation.name,
                style: textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(
              distanceKm != null
                  ? '${distanceKm!.toStringAsFixed(1)} km away · Sleeps ${accommodation.accommodationDetails.numberOfBeds}'
                  : 'Sleeps ${accommodation.accommodationDetails.numberOfBeds}',
              style: textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            RichText(
              text: TextSpan(
                style: textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '\$${accommodation.pricePerNight.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: ' / night',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
