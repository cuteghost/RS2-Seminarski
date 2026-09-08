import 'package:ebooking/widgets/remote_image.dart';

import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/screens/customer_screens/search_screen.dart';
import 'package:ebooking/widgets/custom_partner_bottom_navigation_bar.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/utils/session_utils.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/accommodation_details_screen.dart';
import 'package:ebooking/screens/customer_screens/history_screen.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class PartnerDiscoverPage extends StatefulWidget {
  const PartnerDiscoverPage({super.key});

  @override
  DiscoverPropertiesPageState createState() => DiscoverPropertiesPageState();
}

class DiscoverPropertiesPageState extends State<PartnerDiscoverPage> {
  Position? _currentPosition;
  // Null while the request is still out, so the spinner means loading
  // rather than empty -- an empty result used to spin forever.
  List<AccommodationGET>? _nearbyAccommodations;
  String? _nearbyError;

  @override
  void initState() {
    super.initState();
    _loadNearby();
  }

  Future<void> _getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
    }
  }

  Future<void> _loadNearby() async {
    await _getCurrentLocation();
    if (!mounted) return;
    if (_currentPosition == null) {
      setState(() => _nearbyAccommodations = <AccommodationGET>[]);
      return;
    }
    try {
      final nearby =
          await Provider.of<AccommodationProvider>(
            context,
            listen: false,
          ).fetchNearbyAccommodations(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
      if (!mounted) return;
      setState(() => _nearbyAccommodations = nearby);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _nearbyAccommodations = <AccommodationGET>[];
        _nearbyError = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final (signedOut, message) = await signOut(context);
              if (!signedOut) {
                messenger.showSnackBar(SnackBar(content: Text(message)));
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Input
            ColoredBox(
              color: Colors.grey.shade200,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SearchAccommodationsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Search for location or property',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(width: 8.0),
                      Icon(Icons.search),
                    ],
                  ),
                ),
              ),
            ),
            // Nearby Properties Header
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Nearby Accommodations',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            // Nearby Properties Horizontal Scroll
            if (_nearbyAccommodations == null)
              const Center(child: CircularProgressIndicator())
            else if (_nearbyAccommodations!.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  _nearbyError ?? 'No accommodations within 10 km of you.',
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _nearbyAccommodations!.length,
                    (index) => InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccommodationDetailsScreen(
                              accommodation: _nearbyAccommodations![index],
                            ),
                          ),
                        );
                      },
                      child: NearbyPropertyCard(
                        imageUrl: _nearbyAccommodations![index].firstImageUrl,
                        propertyName: _nearbyAccommodations![index].name,
                        pricePerNight:
                            _nearbyAccommodations![index].pricePerNight,
                      ),
                    ),
                  ),
                ),
              ),
            // Property Header
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Accommodation Quick Filters',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            // Filters Horizontal Scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Pool'),
                    onSelected: (bool selected) {},
                  ),
                  const SizedBox(width: 8.0),
                  FilterChip(
                    label: const Text('Bathub'),
                    onSelected: (bool selected) {},
                  ),
                  const SizedBox(width: 8.0),
                  FilterChip(
                    label: const Text('Terrace'),
                    onSelected: (bool selected) {},
                  ),
                  const SizedBox(width: 8.0),
                  FilterChip(
                    label: const Text('View'),
                    onSelected: (bool selected) {},
                  ),
                  const SizedBox(width: 8.0),
                  FilterChip(
                    label: const Text('Sea View'),
                    onSelected: (bool selected) {},
                  ),
                ],
              ),
            ),
            // Reservation History
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reservation History',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReservationHistoryPage(),
                        ),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomPartnerBottomNavigationBar(
        currentIndex: 0,
      ),
    );
  }
}

class NearbyPropertyCard extends StatelessWidget {
  final String? imageUrl;
  final String propertyName;
  final double pricePerNight;

  const NearbyPropertyCard({
    super.key,
    required this.imageUrl,
    required this.propertyName,
    required this.pricePerNight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      width: 200.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Image
          Container(
            height: 100.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade200,
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: RemoteImage(path: imageUrl, width: double.infinity),
          ),
          const SizedBox(height: 8.0),
          Text(
            propertyName,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const Text('Less than 10km away', style: TextStyle(fontSize: 12.0)),
          Text(
            '\$ $pricePerNight per night',
            style: const TextStyle(fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}
