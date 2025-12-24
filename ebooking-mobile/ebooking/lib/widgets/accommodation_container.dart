import 'dart:io';

import 'package:flutter/material.dart';

class AccommodationContainer extends StatelessWidget {
  final File image;
  final String propertyName;
  final int reviews;
  final String status;
  final double reviewScore;
  final String price;
  final VoidCallback? onTap;

  AccommodationContainer({
    required this.image,
    required this.propertyName,
    required this.reviews,
    required this.status,
    required this.reviewScore,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(16.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            // Property Image
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: FileImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16.0),
            // Property Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    propertyName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  Text('$reviews reviews'),
                  Text('Status: $status'),
                ],
              ),
            ),
            // Review Score and Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundColor: Colors.blue,
                  child: Text(
                    reviewScore.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  '$price \$',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}