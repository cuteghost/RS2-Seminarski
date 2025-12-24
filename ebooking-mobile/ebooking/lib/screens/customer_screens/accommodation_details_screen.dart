import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/booking_screen.dart';

class AccommodationDetailsScreen extends StatefulWidget {
  final AccommodationGET accommodation;

  AccommodationDetailsScreen({required this.accommodation});

  @override
  _AccommodationDetailsScreenState createState() => _AccommodationDetailsScreenState();
}


class _AccommodationDetailsScreenState extends State<AccommodationDetailsScreen> {
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
            Container(
              height: 200.0,
              child: PageView.builder(
                itemCount: accommodation.images.images.length, // Number of property images
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.all(8.0),
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
                    ],
                  ),
                  SizedBox(height: 8.0),
                  // Address
                  Text('Address: ${accommodation.location.address}'),
                  SizedBox(height: 8.0),
                  // Check-in Hours
                  Text('Check-in Hours: 12:00 - 22:00'),
                  SizedBox(height: 8.0),
                  // Price
                  Text('\$${accommodation.pricePerNight} per night'),
                  SizedBox(height: 16.0),
                  // Short Description
                  Text(
                    '${accommodation.description}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 16.0),
                  // Reserve Now Button
                  Center( 
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle reservation logic
                        // Navigate to the BookingScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookingScreen(accommodation: accommodation),
                          ),
                        );
                      },
                      child: Text('Reserve Now'),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  // Recommended Sites
                  // Text(
                  //   'Recommended Sites to Visit',
                  //   style: TextStyle(
                  //     fontSize: 18.0,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // SizedBox(height: 8.0),
                  // Two Recommended Sites
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     RecommendedSiteCard(
                  //         title: 'Site 1',
                  //         imagePath: 'assets/images/Image.jpeg'),
                  //     RecommendedSiteCard(
                  //         title: 'Site 2',
                  //         imagePath: 'assets/images/Image.jpeg'),
                  //   ],
                  // ),
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

// class RecommendedSiteCard extends StatelessWidget {
//   final String title;
//   final String imagePath;

//   RecommendedSiteCard({required this.title, required this.imagePath});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 150.0,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Recommended Site Image
//           Container(
//             height: 100.0,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(8.0),
//               image: DecorationImage(
//                 image: AssetImage(imagePath),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           SizedBox(height: 8.0),
//           // Recommended Site Title
//           Text(title),
//         ],
//       ),
//     );
//   }
// }
