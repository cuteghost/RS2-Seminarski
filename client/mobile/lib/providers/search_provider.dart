import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/services/search_service.dart';
import 'package:flutter/material.dart';

class SearchProvider with ChangeNotifier {
  final SearchService _searchService;
  SearchProvider({required this._searchService});

  Future<Paged<AccommodationGET>> search(
    SearchCriteria criteria, {
    int page = ApiPagination.firstPage,
  }) {
    return _searchService.search(criteria, page: page);
  }
}
