import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/screens/partner_screens/accommodation_screen.dart';
import 'package:ebooking/screens/partner_screens/add_accommodation_screen.dart';
import 'package:ebooking/widgets/custom_partner_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/widgets/accommodation_container.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

class MyAccommodationsScreen extends StatefulWidget {
  const MyAccommodationsScreen({super.key});

  @override
  State<MyAccommodationsScreen> createState() => _MyAccommodationsScreenState();
}

class _MyAccommodationsScreenState extends State<MyAccommodationsScreen> {
  late Future<List<AccommodationGET>> _future;

  @override
  void initState() {
    super.initState();
    _future = Provider.of<AccommodationProvider>(context, listen: false)
        .getMyAccommodations();
  }

  void _reload() {
    setState(() {
      _future = Provider.of<AccommodationProvider>(context, listen: false)
          .getMyAccommodations();
    });
  }

  Future<void> _publish(AccommodationGET accommodation) async {
    final patch = AccommodationPATCH(
      id: accommodation.id,
      status: true,
      name: accommodation.name,
      typeOfAccommodation: accommodation.typeOfAccommodation,
      pricePerNight: accommodation.pricePerNight,
      description: accommodation.description,
      accommodationDetails: accommodation.accommodationDetails,
      images: accommodation.images,
    );
    final success =
        await Provider.of<AccommodationProvider>(context, listen: false)
            .updateAccommodation(patch);
    if (!mounted) return;
    if (success) {
      _reload();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't publish this listing. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<AccommodationGET>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}', style: textTheme.bodySmall),
              );
            }

            final accommodations = snapshot.data ?? [];
            final liveCount = accommodations.where((a) => a.status).length;

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
                            Text('Your properties', style: textTheme.headlineMedium),
                            const SizedBox(height: 3),
                            Text('${accommodations.length} listings · $liveCount live',
                                style: textTheme.bodySmall),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddAccommodationScreen()),
                          );
                          _reload();
                        },
                        icon: Icon(PhosphorIcons.plus(), size: 14),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                if (accommodations.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'BOOKINGS',
                            value: '${accommodations.length}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            label: 'RATING',
                            value: accommodations.any((a) => a.reviewScore > 0)
                                ? (accommodations
                                            .map((a) => a.reviewScore)
                                            .reduce((a, b) => a + b) /
                                        accommodations.length)
                                    .toStringAsFixed(1)
                                : '—',
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 18),
                Expanded(
                  child: accommodations.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(PhosphorIcons.houseLine(),
                                    size: 32, color: AppColors.textTertiary),
                                const SizedBox(height: 14),
                                Text('No properties yet', style: textTheme.titleMedium),
                                const SizedBox(height: 6),
                                Text(
                                  'Add your first listing to start taking bookings.',
                                  style: textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: accommodations.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final accommodation = accommodations[index];
                            final image = accommodation.images.images.isNotEmpty
                                ? accommodation.images.images.first
                                : null;
                            return AccommodationContainer(
                              image: image,
                              propertyName: accommodation.name,
                              reviews: accommodation.reviews.length,
                              isAvailable: accommodation.status,
                              reviewScore: accommodation.reviewScore,
                              price: accommodation.pricePerNight
                                  .toStringAsFixed(0),
                              numberOfBeds:
                                  accommodation.accommodationDetails.numberOfBeds,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccommodationScreen(
                                        accommodation: accommodation),
                                  ),
                                );
                                _reload();
                              },
                              onPublish: () => _publish(accommodation),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const CustomPartnerBottomNavigationBar(currentIndex: 0),
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
