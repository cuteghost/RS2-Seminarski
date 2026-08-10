import 'package:ebooking_desktop/models/accomodation_model.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:flutter/material.dart';
import 'package:ebooking_desktop/widgets/drawer.dart';
import 'package:provider/provider.dart';

class PropertyManagementPage extends StatelessWidget {
  const PropertyManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    const crossAxisCount = 6;
    final accommodations = Provider.of<AdminProvider>(context, listen: false).accommodations;
    return Scaffold(
    drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Property Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search action
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount, // Adjust based on screen size
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1 / 1.2, // Adjust the aspect ratio of the card
        ),
        itemCount: accommodations.length, // The number of items to show
        itemBuilder: (context, index) {
          return PropertyCard(accommodation: accommodations[index]);
        },
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final AccommodationGET accommodation;
  
  const PropertyCard({super.key, required this.accommodation});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Rounded corners for Card
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image(
              image: FileImage(accommodation.images.images[0]!),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              accommodation.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(accommodation.location.address), // Replace with actual property location
          ),
          OverflowBar(
            alignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Handle directions action
                },
              ),
],
          ),
        ],
      ),
    );
  }
}
