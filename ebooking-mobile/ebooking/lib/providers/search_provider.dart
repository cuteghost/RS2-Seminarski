import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/services/reservation_service.dart';
import 'package:ebooking/services/search_service.dart';
import 'package:flutter/material.dart';

class SearchProvider with ChangeNotifier
{
  final SearchService _searchService;
  SearchProvider({required SearchService searchService}) : _searchService = searchService;

  Future<List<AccommodationGET>> search(double priceFrom, double priceTo, String city, DateTime checkIn, DateTime checkOut) async {
     return await _searchService.search(priceFrom, priceTo, city, checkIn, checkOut);
  }
}