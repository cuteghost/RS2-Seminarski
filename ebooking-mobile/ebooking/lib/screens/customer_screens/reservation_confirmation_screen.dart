import 'package:ebooking/screens/customer_screens/discover_screen.dart';
import 'package:flutter/material.dart';

class ReservationConfirmationPage extends StatelessWidget {
  final String accommodationName;
  ReservationConfirmationPage({required this.accommodationName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation Confirmation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thank you header
            Text(
              'Thank you for your reservation.',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),

            // Success message
            Text(
              'You have successfully paid your stay at ${accommodationName}.',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.0),

            // Checked-out icon
            Icon(
              Icons.check_circle,
              size: 100.0,
              color: Colors.green,
            ),
            SizedBox(height: 32.0),

            // Back Home button
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DiscoverPropertiesPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
              ),
              child: Text('Back Home'),
            ),
          ],
        ),
      ),
    );
  }
}
