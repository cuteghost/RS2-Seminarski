import 'dart:io';

import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/providers/reservation_provide.dart';
import 'package:ebooking/screens/customer_screens/accommodation_details_screen.dart';
import 'package:ebooking/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/feedback_screen.dart';
import 'package:provider/provider.dart';

class ReservationHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Reservation History'),
        ),
        body: FutureBuilder<List<ReservationGET>>(
          future: Provider.of<ReservationProvider>(context, listen: false).fetchMyReservations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('Stack trace: ${snapshot.stackTrace}');
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var reservation = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildReservationCard(
                      reservation.accommodation!.name,
                      '${reservation.startDate} - ${reservation.endDate}',
                      reservation.accommodation!.reviewScore,
                      reservation.isRated,
                      reservation.accommodation!.reviewScore,
                      reservation.thumbnail,
                      reservation.accommodation!.id,
                      reservation.accommodation!,
                      context
                    ),
                  );
                },
              );
            }
          }
        ),
        bottomNavigationBar: CustomBottomNavigationBar());
  }

  Widget _buildReservationCard(
    String placeName, 
    String dateRange, 
    double rating, 
    bool rated, 
    double? reviewScore,
    File image,
    String accommodationId,
    AccommodationGET accommodation,
    BuildContext context
    ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          // Left side with image
          Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0),
              ),
              image: DecorationImage(
                image: FileImage(image),
                fit: BoxFit.cover,
              ),
            ),
            
          ),
          SizedBox(width: 16.0),
          // Right side with details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with place name
                Text(
                  placeName,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                // Dates
                Text(
                  dateRange,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8.0),
                // Rating stars
                if (rated)
                  Row(children: [
                    CircleAvatar(
                      radius: 15.0,
                      backgroundColor: Colors.blue,
                      child: Text(
                        reviewScore.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Spacer(),
                    Text('Rated by you')
                  ])
                else
                GestureDetector( 
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage(accommodationID: accommodationId)));
                  },
                  child:
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.black,
                        ),
                        Text('Rate your stay')
                      ]
                    )
                  )
              ],
            ),
          ),
          Container(
            width: 50.0,
            height: 120.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
          ),
          // Pokuso pokuso
          // Right sign
          // IconButton(
          //   icon: Icon(
          //     Icons.arrow_right,
          //     size: 30.0,
          //     color: Colors.blue,
          //   ),
          //   onPressed: () {
          //     Navigator.push(context, MaterialPageRoute(builder: (context) => AccommodationDetailsScreen(accommodation: accommodation)));
          //   },            
          // ),

        ],
      ),
    );
  }
}
