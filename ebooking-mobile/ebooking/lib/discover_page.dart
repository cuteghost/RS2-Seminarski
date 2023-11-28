import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'property_details_page.dart';

class DiscoverPropertiesPage extends StatelessWidget {
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
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for location or property          ->',
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
                      // Handle reservation history button press
                    },
                    child: Text('View All'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Suggestions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
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
