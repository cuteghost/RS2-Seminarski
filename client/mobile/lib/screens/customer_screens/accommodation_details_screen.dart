import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/booking_screen.dart';

class AccommodationDetailsScreen extends StatefulWidget {
  final AccommodationGET accommodation;

  const AccommodationDetailsScreen({super.key, required this.accommodation});

  @override
  AccommodationDetailsScreenState createState() =>
      AccommodationDetailsScreenState();
}

class AccommodationDetailsScreenState
    extends State<AccommodationDetailsScreen> {
  late AccommodationGET accommodation;

  @override
  void initState() {
    super.initState();
    accommodation = widget.accommodation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${accommodation.name} Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Gallery
            SizedBox(
              height: 200.0,
              child: PageView.builder(
                itemCount: accommodation.images.images.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: FileImage(accommodation.images.images[index]!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Property Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Property Name',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text('Address: ${accommodation.location.address}'),
                  const SizedBox(height: 8.0),
                  const Text('Check-in Hours: 12:00 - 22:00'),
                  const SizedBox(height: 8.0),
                  Text('\$${accommodation.pricePerNight} per night'),
                  const SizedBox(height: 16.0),
                  Text(
                    accommodation.description,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookingScreen(accommodation: accommodation),
                          ),
                        );
                      },
                      child: const Text('Reserve Now'),
                    ),
                  ),
                  const SizedBox(height: 16.0),
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
