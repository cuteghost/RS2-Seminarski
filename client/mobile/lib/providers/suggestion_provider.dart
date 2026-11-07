import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/services/suggestions_service.dart';
import 'package:flutter/material.dart';

class SuggestionProvider with ChangeNotifier {
  final SuggestionsService _suggestionService;
  SuggestionProvider({required this._suggestionService});

  /// No customer id: the server reads it from the token, so one signed-in
  /// user can no longer ask for another one's recommendations.
  Future<List<AccommodationGET>> suggest({double? latitude, double? longitude}) {
    return _suggestionService.fetchRecommendations(
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<List<AccommodationGET>> similarTo(String accommodationId) {
    return _suggestionService.fetchSimilar(accommodationId);
  }
}
