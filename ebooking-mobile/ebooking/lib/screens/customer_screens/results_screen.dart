import 'dart:io';

import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/screens/customer_screens/accommodation_details_screen.dart';
import 'package:ebooking/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/filters_screen.dart';

class SearchResultPage extends StatefulWidget {
  final List<AccommodationGET> accommodations;
  final int numberOfDays;

  SearchResultPage({required this.accommodations, required this.numberOfDays});

  @override
  _SearchResultsState createState() => _SearchResultsState();
}


class _SearchResultsState extends State<SearchResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: Column(
          children: [
            // Filters
            Container(
              margin: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(onPressed:() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FiltersPage()));
                  }, 
                  child: RoundedFilterButton(icon: Icons.filter_list, label: 'Filters')),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.accommodations.length, 
                itemBuilder: (context, index){
                  var accommodation = widget.accommodations[index];
                  return SearchResultContainer(
                    image: accommodation.images.images[0]!,
                    propertyName: accommodation.name,
                    pricePerNight: accommodation.pricePerNight,
                    reviewScore: accommodation.reviewScore,
                    totalPrice: '\$${accommodation.pricePerNight * widget.numberOfDays}',
                    address: accommodation.location.address,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccommodationDetailsScreen(accommodation: accommodation)));
                    },
                  );
                }),
            ),
          ],
        ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}

class RoundedFilterButton extends StatelessWidget {
  final IconData icon;
  final String label;

  RoundedFilterButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 8.0),
          Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

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
