import 'package:ebooking/models/city_model.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/models/location_model.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/services/location_service.dart';

class LocationProvider with ChangeNotifier {
  List<Country> _countries = [];
  List<City> _cities = [];

  List<Country> get countries => _countries;
  List<City> get cities => _cities;

  final LocationService _locationService = LocationService();

  Future<void> fetchCountries() async {
    _countries = await _locationService.getCountries();
    notifyListeners();
  }

  Future<void> fetchCities(String? countryId) async {
    _cities = await _locationService.getCities(countryId);
    notifyListeners();
  }
  Future<List<double>> craftGeoCode(String geoCodeInfo) async {
    return await _locationService.geoCode(geoCodeInfo);
  }
  Future<String> createLocation(Location location) async {
    return await _locationService.createLocation(location);
  }
  Future<Country?> getCountry(String countryId) async {
    return await _locationService.getCountry(countryId);
  }
}
