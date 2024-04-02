import 'package:flutter/material.dart';
import 'package:ebooking/services/country_service.dart';
import 'package:ebooking/services/city_service.dart';

class LocationProvider with ChangeNotifier {
  List<dynamic> _countries = [];
  List<dynamic> _cities = [];

  List<dynamic> get countries => _countries;
  List<dynamic> get cities => _cities;

  final CountryService _countryService = CountryService();
  final CityService _cityService = CityService();

  Future<void> fetchCountries() async {
    _countries = await _countryService.getCountries();
    notifyListeners();
  }

  Future<void> fetchCities() async {
    _cities = await _cityService.getCities();
    notifyListeners();
  }
}
