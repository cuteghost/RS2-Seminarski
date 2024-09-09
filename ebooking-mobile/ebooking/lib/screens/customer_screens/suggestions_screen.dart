import 'package:ebooking/providers/suggestion_provider.dart';
import 'package:ebooking/screens/customer_screens/accommodation_details_screen.dart';
import 'package:ebooking/widgets/suggestion_container.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/services/suggestions_service.dart';
import 'package:provider/provider.dart';

class SuggestionsScreen extends StatefulWidget {
  final String customerId;

  SuggestionsScreen({required this.customerId});

  @override
  _SuggestionsScreenState createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  late Future<List<dynamic>> _recommendations;

  @override
  void initState() {
    super.initState();
    _recommendations = Provider.of<SuggestionProvider>(context, listen: false).suggest(widget.customerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Suggestions'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _recommendations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load recommendations'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No recommendations available'));
          } else {
            var recommendations = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      var accommodation = recommendations[index];
                      return SuggestionContainer(
                        image: accommodation.images.images[0]!,
                        propertyName: accommodation.name,
                        pricePerNight: accommodation.pricePerNight,
                        reviewScore: accommodation.reviewScore,
                        address: accommodation.location.address,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AccommodationDetailsScreen(accommodation: accommodation),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
