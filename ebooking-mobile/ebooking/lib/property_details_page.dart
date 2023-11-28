import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'booking_page.dart';

class PropertyDetailsPage extends StatelessWidget {
  final int propertyIndex;

  PropertyDetailsPage({required this.propertyIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Property Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Gallery
            Container(
              height: 200.0,
              child: PageView.builder(
                itemCount: 3, // Number of property images
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/images/property_image_$index.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Property Details
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Name and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Property Name',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'AVAILABLE', // Replace with property status
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  // Address
                  Text('Address: Dzemala Bijedica 96'),
                  SizedBox(height: 8.0),
                  // Check-in Hours
                  Text('Check-in Hours: 12:00 - 22:00'),
                  SizedBox(height: 8.0),
                  // Price
                  Text('\$1200 per night'),
                  SizedBox(height: 16.0),
                  // Short Description
                  Text(
                    'Short description about the property.',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  // Reserve Now Button
                  ElevatedButton(
                    onPressed: () {
                      // Handle reservation logic
                      // Navigate to the BookingScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingScreen(),
                        ),
                      );
                    },
                    child: Text('Reserve Now'),
                  ),
                  SizedBox(height: 16.0),
                  // Recommended Sites
                  Text(
                    'Recommended Sites to Visit',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  // Two Recommended Sites
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RecommendedSiteCard(
                          title: 'Site 1',
                          imagePath: 'assets/images/Image.jpeg'),
                      RecommendedSiteCard(
                          title: 'Site 2',
                          imagePath: 'assets/images/Image.jpeg'),
                    ],
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

class RecommendedSiteCard extends StatelessWidget {
  final String title;
  final String imagePath;

  RecommendedSiteCard({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommended Site Image
          Container(
            height: 100.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          // Recommended Site Title
          Text(title),
        ],
      ),
    );
  }
}
