import 'package:ebooking/screens/property_details_screen.dart';
import 'package:ebooking/widgets/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/filters_screen.dart';

class SearchResultsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: SingleChildScrollView(
        child: Column(
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
            // Search Results
            SearchResultContainer(
                image: 'assets/images/property_image_1.jpg',
                propertyName: 'Beautiful Villa',
                reviews: 15,
                status: 'Available',
                reviewScore: 9.2,
                price: '\$1000',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailsPage(propertyIndex: 0)));
                }),
            SearchResultContainer(
                image: 'assets/images/property_image_2.jpg',
                propertyName: 'Luxury Apartment',
                reviews: 20,
                status: 'Unavailable',
                reviewScore: 8.8,
                price: '\$1200',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailsPage(propertyIndex: 0)));
                }),
            SearchResultContainer(
                image: 'assets/images/property_image_2.jpg',
                propertyName: 'Luxury Apartment',
                reviews: 20,
                status: 'Unavailable',
                reviewScore: 8.8,
                price: '\$1200',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailsPage(propertyIndex: 0)));
                }),
            SearchResultContainer(
                image: 'assets/images/property_image_2.jpg',
                propertyName: 'Luxury Apartment',
                reviews: 20,
                status: 'Unavailable',
                reviewScore: 8.8,
                price: '\$1200',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailsPage(propertyIndex: 0)));
                }),
            SearchResultContainer(
                image: 'assets/images/property_image_2.jpg',
                propertyName: 'Luxury Apartment',
                reviews: 20,
                status: 'Unavailable',
                reviewScore: 8.8,
                price: '\$1200',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailsPage(propertyIndex: 0)));
                }),
            SearchResultContainer(
                image: 'assets/images/property_image_2.jpg',
                propertyName: 'Luxury Apartment',
                reviews: 20,
                status: 'Unavailable',
                reviewScore: 8.8,
                price: '\$1200',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailsPage(propertyIndex: 0)));
                }),
            SearchResultContainer(
                image: 'assets/images/property_image_2.jpg',
                propertyName: 'Luxury Apartment',
                reviews: 20,
                status: 'Unavailable',
                reviewScore: 8.8,
                price: '\$1200',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailsPage(propertyIndex: 0)));
                }),
            SearchResultContainer(
                image: 'assets/images/property_image_2.jpg',
                propertyName: 'Luxury Apartment',
                reviews: 20,
                status: 'Unavailable',
                reviewScore: 8.8,
                price: '\$1200',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailsPage(propertyIndex: 0)));
                }),
            SearchResultContainer(
                image: 'assets/images/property_image_2.jpg',
                propertyName: 'Luxury Apartment',
                reviews: 20,
                status: 'Unavailable',
                reviewScore: 8.8,
                price: '\$1200',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailsPage(propertyIndex: 0)));
                }),
            SearchResultContainer(
                image: 'assets/images/property_image_2.jpg',
                propertyName: 'Luxury Apartment',
                reviews: 20,
                status: 'Unavailable',
                reviewScore: 8.8,
                price: '\$1200',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailsPage(propertyIndex: 0)));
                }),
            // Add more SearchResultContainer widgets for additional results
          ],
        ),
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
  final String image;
  final String propertyName;
  final int reviews;
  final String status;
  final double reviewScore;
  final String price;
  final VoidCallback? onTap;

  SearchResultContainer({
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
                  image: AssetImage(image),
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
                  price,
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
