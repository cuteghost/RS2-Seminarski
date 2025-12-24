import 'dart:io';
import 'package:flutter/material.dart';

class SearchResultContainer extends StatelessWidget {
  final File image;
  final String propertyName;
  final double pricePerNight;
  final double reviewScore;
  final String totalPrice;
  final String address;
  final VoidCallback? onTap;

  SearchResultContainer({
    required this.image,
    required this.propertyName,
    required this.pricePerNight,
    required this.reviewScore,
    required this.totalPrice,
    required this.address,
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
                  Text('\$${pricePerNight} per Night'),
                  Text('Address: $address'),
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
                  totalPrice,
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
