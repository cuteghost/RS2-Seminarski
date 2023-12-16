import 'package:ebooking/search_page.dart';
import 'package:ebooking/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/property_details_page.dart';
import 'package:ebooking/history_page.dart';

class DiscoverPropertiesPage extends StatefulWidget {
  @override
  _DiscoverPropertiesPageState createState() => _DiscoverPropertiesPageState();
}

class _DiscoverPropertiesPageState extends State<DiscoverPropertiesPage> {
  void _openSearchAccommodations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchAccommodationsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover Properties'),
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
                      builder: (context) => SearchAccommodationsPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey.shade200,
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
                'Nearby Properties',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Nearby Properties Horizontal Scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  5, // Number of nearby properties
                  (index) => InkWell(
                    onTap: () {
                      // Navigate to PropertyDetailsPage when a property is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailsPage(propertyIndex: index),
                        ),
                      );
                    },
                    child: NearbyPropertyCard(),
                  ),
                ),
              ),
            ),
            // Property Header
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Property',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Filters Horizontal Scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  8, // Number of filters
                  (index) => FilterChip(
                    label: Text('Filter $index'),
                    onSelected: (bool selected) {},
                  ),
                ),
              ),
            ),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      width: 150.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Image
          Container(
            height: 100.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: AssetImage('assets/images/Image.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          // Distance from Current Location
          Text(
            'Property',
            style: TextStyle(fontSize: 16.0),
          ),
          Text(
            '50 meters from here',
            style: TextStyle(fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}
