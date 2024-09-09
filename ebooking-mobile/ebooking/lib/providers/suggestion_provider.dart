import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/services/suggestions_service.dart';
import 'package:flutter/material.dart';

class SuggestionProvider with ChangeNotifier
{
  final SuggestionsService _suggestionService;
  SuggestionProvider({required SuggestionsService suggestionService}) : _suggestionService = suggestionService;

  Future<List<AccommodationGET>> suggest(String customerId) async {
     return await _suggestionService.fetchRecommendations(customerId);
  }
}