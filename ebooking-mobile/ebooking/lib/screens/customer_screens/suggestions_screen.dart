import 'package:flutter/material.dart';

class SuggestionsForYou extends StatefulWidget {
  @override
  _SuggestionsForYouState createState() => _SuggestionsForYouState();
}

class _SuggestionsForYouState extends State<SuggestionsForYou> {
  List<Accommodation> suggestions = [
    Accommodation(
      name: 'Grand Hotel',
      rating: 9.1,
      type: 'Luxury',
      reviews: 908,
      isOpen: true,
    ),
    Accommodation(
      name: 'Beach Resort',
      rating: 8.6,
      type: 'Tropical Getaway',
      reviews: 420,
      isOpen: true,
    ),
    Accommodation(
      name: 'City',
      rating: 8.2,
      type: 'Urban Living',
      reviews: 811,
      isOpen: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suggestions For You'),
      ),
      body: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return AccommodationCard(suggestions[index]);
        },
      ),
    );
  }
}

class AccommodationCard extends StatelessWidget {
  final Accommodation accommodation;

  AccommodationCard(this.accommodation);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Text(accommodation.name),
              Spacer(),
              Text('${accommodation.rating}'),
            ],
          ),
          Text(accommodation.type),
          Text('${accommodation.reviews} reviews'),
          if (accommodation.isOpen) Text('Open now'),
        ],
      ),
    );
  }
}

class Accommodation {
  final String name;
  final double rating;
  final String type;
  final int reviews;
  final bool isOpen;

  Accommodation({
    required this.name,
    required this.rating,
    required this.type,
    required this.reviews,
    required this.isOpen,
  });
}
