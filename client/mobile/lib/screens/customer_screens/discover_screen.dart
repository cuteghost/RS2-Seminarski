import 'dart:io';

import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/screens/login_screen.dart';
import 'package:ebooking/screens/customer_screens/search_screen.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/accommodation_details_screen.dart';
import 'package:ebooking/screens/customer_screens/history_screen.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class DiscoverPropertiesPage extends StatefulWidget {
  const DiscoverPropertiesPage({super.key});

  @override
  DiscoverPropertiesPageState createState() => DiscoverPropertiesPageState();
}

class DiscoverPropertiesPageState extends State<DiscoverPropertiesPage> {
  Position? _currentPosition;
  List<AccommodationGET> _nearbyAccommodations = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) {
      _getNearbyAccommodations().then((value) {
        setState(() {
          _nearbyAccommodations = value;
        });
      });
    });
  }

  Future<void> _getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
    }
  }

  Future<List<AccommodationGET>> _getNearbyAccommodations() async {
    if (_currentPosition != null) {
      var nearby =
          await Provider.of<AccommodationProvider>(context, listen: false)
              .fetchNearbyAccommodations(
                  _currentPosition!.latitude, _currentPosition!.longitude);
      return nearby;
    } else {
      List<AccommodationGET> empty = [];
      return empty;
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
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
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
                    children: [
                      const Text(
                        'Search for location or property',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(width: 8.0),
                      const Icon(Icons.search),
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
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Nearby Properties Horizontal Scroll
            _nearbyAccommodations.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        _nearbyAccommodations.length,
                        (index) => InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AccommodationDetailsScreen(
                                        accommodation:
                                            _nearbyAccommodations[index]),
                              ),
                            );
                          },
                          child: NearbyPropertyCard(
                            image:
                                _nearbyAccommodations[index].images.images[0]!,
                            propertyName: _nearbyAccommodations[index].name,
                            pricePerNight:
                                _nearbyAccommodations[index].pricePerNight,
                          ),
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
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
                          builder: (context) =>
                              const ReservationHistoryPage(),
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
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class NearbyPropertyCard extends StatelessWidget {
  final File image;
  final String propertyName;
  final double pricePerNight;

  const NearbyPropertyCard(
      {super.key,
      required this.image,
      required this.propertyName,
      required this.pricePerNight});

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
              image: DecorationImage(
                image: FileImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            propertyName,
            style:
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Less than 10km away',
            style: TextStyle(fontSize: 12.0),
          ),
          Text(
            '\$ $pricePerNight per night',
            style: const TextStyle(fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}
