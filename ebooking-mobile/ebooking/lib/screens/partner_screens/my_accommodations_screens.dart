import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/providers/accommodation_provider.dart';
import 'package:ebooking/screens/customer_screens/accommodation_details_screen.dart';
import 'package:ebooking/screens/partner_screens/accommodation_screen.dart';
import 'package:ebooking/widgets/CustomBottomNavigationBar.dart';
import 'package:ebooking/widgets/CustomPartnerBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/filters_screen.dart';
import 'package:ebooking/widgets/accommodation_container.dart';
import 'package:provider/provider.dart';

class MyAccommodationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Accommodations'),
      ),
      body: FutureBuilder<List<AccommodationGET>>(
              future: Provider.of<AccommodationProvider>(context, listen: false).getMyAccommodations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  print('Stack trace: ${snapshot.stackTrace}');
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            var accommodation = snapshot.data![index];
                            return AccommodationContainer(
                              image: accommodation.images.images[0]!,
                              propertyName: accommodation.name,
                              reviews: accommodation.reviews!.length,
                              status: accommodation.status! ? 'Available' : 'Not Available',
                              reviewScore: 0.0,
                              price: accommodation.pricePerNight.toString(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccommodationScreen(accommodation: accommodation),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: snapshot.data!.length,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
      bottomNavigationBar: CustomPartnerBottomNavigationBar(),
    );
  }
}


