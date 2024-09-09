import 'dart:io';

import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/screens/customer_screens/suggestions_screen.dart';
import 'package:ebooking/screens/login_screen.dart';
import 'package:ebooking/screens/customer_screens/search_screen.dart';
import 'package:ebooking/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/accommodation_details_screen.dart';
import 'package:ebooking/screens/customer_screens/history_screen.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class DiscoverPropertiesPage extends StatefulWidget {
  @override
  _DiscoverPropertiesPageState createState() => _DiscoverPropertiesPageState();
}

class _DiscoverPropertiesPageState extends State<DiscoverPropertiesPage> {
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
      desiredAccuracy: LocationAccuracy.high,
    );
    if(mounted)
    {  
      setState(() {
        _currentPosition = position;
      });
    }
  }

  Future<List<AccommodationGET>> _getNearbyAccommodations() async {
    if(_currentPosition != null){
      var nearby = await Provider.of<AccommodationProvider>(context, listen: false)
          .fetchNearbyAccommodations(_currentPosition!.latitude, _currentPosition!.longitude);
     return nearby;
    }
    else {
      print('Current position is null');
      List<AccommodationGET> empty = [];
      return empty;
    }
  }

  
  void _openSearchAccommodations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchAccommodationsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover Properties'),
        actions: //logout button
        [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              // Navigate to the LoginScreen
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Input
              Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.grey.shade200,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the SearchAccommodationsPage when the button is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchAccommodationsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Search for location or property',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(width: 8.0), // Adjust spacing
                      Icon(Icons.search),
                    ],
                  ),
                ),
              ),
            // Nearby Properties Header
            Padding(
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
            !_nearbyAccommodations.isEmpty ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:List.generate(
                  _nearbyAccommodations.length, // Number of nearby properties
                  (index) => InkWell(
                    onTap: () {
                      // Navigate to PropertyDetailsPage when a property is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AccommodationDetailsScreen(accommodation: _nearbyAccommodations[index]),
                        ),
                      );
                    },
                    child: NearbyPropertyCard(image: _nearbyAccommodations[index].images.images[0]!, propertyName: _nearbyAccommodations[index].name, pricePerNight: _nearbyAccommodations[index].pricePerNight,),
                  ),
                ),
              ),
            ) : Container(child: Center(child: CircularProgressIndicator(),),),
            // Property Header
            // Padding(
            //   padding: EdgeInsets.all(16.0),
            //   child: Text(
            //     'Accommodation Quick Filters',
            //     style: TextStyle(
            //       fontSize: 18.0,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            // // Filters Horizontal Scroll
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     children: [
            //         FilterChip(
            //           label: Text('Pool'),
            //           onSelected: (bool selected) {},
            //         ),
            //         SizedBox(width: 8.0),
            //         FilterChip(
            //           label: Text('Bathub'),
            //           onSelected: (bool selected) {},
            //         ),
            //         SizedBox(width: 8.0),
            //         FilterChip(
            //           label: Text('Terrace'),
            //           onSelected: (bool selected) {},
            //         ),
            //         SizedBox(width: 8.0),
            //         FilterChip(
            //           label: Text('View'),
            //           onSelected: (bool selected) {},
            //         ),
            //         SizedBox(width: 8.0),
            //         FilterChip(
            //           label: Text('Sea View'),
            //           onSelected: (bool selected) {},
            //         ),
            //       ],
            //     ),
            //   ),
            // Reservation History
            Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reservation History',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Handle reservation logic
                      // Navigate to the BookingScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationHistoryPage(),
                        ),
                      );
                    },
                    child: Text('View All'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}

class NearbyPropertyCard extends StatelessWidget {
  final File image;
  final String propertyName;
  final double pricePerNight;

  NearbyPropertyCard({required this.image, required this.propertyName, required this.pricePerNight});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
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
          SizedBox(height: 8.0),
          // Distance from Current Location
          Text(
            propertyName,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          Text(
            'Less than 10km away',
            style: TextStyle(fontSize: 12.0),
          ),
          Text(
            '\$ ${pricePerNight} per night',
            style: TextStyle(fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}
