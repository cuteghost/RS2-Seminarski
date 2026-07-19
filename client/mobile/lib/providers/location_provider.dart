import 'package:ebooking/models/city_model.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/models/location_model.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/services/location_service.dart';
import 'package:flutter/material.dart';

class LocationProvider with ChangeNotifier {
  List<Country> _countries = [];
  List<City> _cities = [];
  String? _error;

  List<Country> get countries => _countries;
  List<City> get cities => _cities;

  /// Why the last dropdown fetch came back empty, in the server's own words.
  /// The screens fill their dropdowns from these lists, so an empty one has to
  /// be able to explain itself rather than just look like there are no cities.
  String? get error => _error;

  final LocationService _locationService;

  LocationProvider({required this._locationService});

  Future<void> fetchCountries() async {
    try {
      _countries = await _locationService.getCountries();
      _error = null;
    } on ApiException catch (e) {
      _countries = <Country>[];
      _error = e.message;
    }
    notifyListeners();
  }

  Future<void> fetchCities(String? countryId) async {
    try {
      _cities = await _locationService.getCities(countryId);
      _error = null;
    } on ApiException catch (e) {
      _cities = <City>[];
      _error = e.message;
    }
    notifyListeners();
  }

  Future<List<double>> craftGeoCode(String geoCodeInfo) {
    return _locationService.geoCode(geoCodeInfo);
  }

  /// The id of the stored location, taken from `data.id`.
  Future<String> createLocation(Location location) {
    return _locationService.createLocation(location);
  }

  Future<Country?> getCountry(String countryId) {
    return _locationService.getCountry(countryId);
  }
}
