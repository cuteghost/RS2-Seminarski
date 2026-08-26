import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/providers/suggestion_provider.dart';
import 'package:ebooking/screens/customer_screens/accommodation_details_screen.dart';
import 'package:ebooking/widgets/suggestion_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class SuggestionsScreen extends StatefulWidget {
  final String customerId;

  const SuggestionsScreen({super.key, required this.customerId});

  @override
  SuggestionsScreenState createState() => SuggestionsScreenState();
}

class SuggestionsScreenState extends State<SuggestionsScreen> {
  late Future<List<dynamic>> _recommendations;

  @override
  void initState() {
    super.initState();
    _recommendations = Provider.of<SuggestionProvider>(context, listen: false)
        .suggest(widget.customerId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Suggested for you')),
      body: FutureBuilder<List<dynamic>>(
        future: _recommendations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load recommendations', style: textTheme.bodySmall),
            );
          }
          final recommendations = snapshot.data ?? [];
          if (recommendations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIcons.sparkle(), size: 32, color: AppColors.textTertiary),
                    const SizedBox(height: 14),
                    Text('No suggestions yet', style: textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Browse and book a few stays and we\u2019ll start suggesting places you might like.',
                      style: textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final accommodation = recommendations[index];
              // Guard against a listing with no photos yet — indexing [0]
              // directly used to throw a RangeError for those.
              final images = accommodation.images.images;
              return SuggestionContainer(
                image: images.isNotEmpty ? images[0] : null,
                propertyName: accommodation.name,
                pricePerNight: accommodation.pricePerNight,
                reviewScore: accommodation.reviewScore,
                address: accommodation.location.address,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AccommodationDetailsScreen(accommodation: accommodation),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
