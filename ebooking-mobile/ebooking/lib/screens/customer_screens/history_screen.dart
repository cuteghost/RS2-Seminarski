import 'package:ebooking/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/feedback_screen.dart';

class ReservationHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Reservation History'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildReservationCard(
                  'Hotel A',
                  '2022-10-01 to 2022-10-05',
                  4, // Rating (out of 5)
                  'assets/images/property_image_0.jpg',
                  true,
                  8.8,
                  context
                  ),
              SizedBox(height: 16.0),
              _buildReservationCard(
                  'Resort B',
                  '2022-08-15 to 2022-08-20',
                  5, // Rating (out of 5)
                  'assets/images/property_image_1.jpg',
                  false,
                  0,
                  context
                  ),

              // Add more reservation cards as needed
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar());
  }

  Widget _buildReservationCard(
    String placeName, 
    String dateRange, 
    int rating,
    String imagePath, 
    bool rated, 
    double? reviewScore,
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
                image: AssetImage(imagePath),
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
                      radius: 20.0,
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackPage()));
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
          // Right sign
          Icon(
            Icons.arrow_right,
            size: 30.0,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
