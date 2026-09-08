import 'dart:convert';

import 'package:ebooking/config/config.dart';
import 'package:ebooking/models/city_model.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/models/location_model.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:http/http.dart' as http;

class LocationService {
  LocationService({required this._apiClient});

  final ApiClient _apiClient;

  /// Countries and cities feed dropdowns, so the whole set is fetched rather
  /// than the first page — a country missing from the list cannot be picked.
  Future<List<Country>> getCountries() {
    return _apiClient.getAllPages<Country>(
      '/api/Country/GetCountries',
      parseItem: Country.fromJson,
    );
  }

  Future<List<City>> getCities(String? countryId) {
    if (countryId == null) {
      throw ApiException(0, 'Pick a country first.');
    }
    return _apiClient.getAllPages<City>(
      '/api/City/GetCityByCountry/$countryId',
      parseItem: City.fromJson,
    );
  }

  /// Google's geocoder, not the eBooking API — it has no `{ message, data }`
  /// envelope and no bearer token, so it does not go through [ApiClient].
  Future<List<double>> geoCode(String geoCodeInfo) async {
    final key = await GoogleConfig.apiKey();
    if (key.isEmpty) {
      throw ApiException(
        0,
        'Address lookup is unavailable: no Google API key is configured. Set '
        'google.api.key in android/local.properties and build the app again.',
      );
    }
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(geoCodeInfo)}&key=$key',
      ),
    );
    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        'Could not look up that address.',
      );
    }
    final Map<String, dynamic> geoCodeJson =
        json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (geoCodeJson['status'] != 'OK') {
      throw ApiException(0, 'No coordinates found for that address.');
    }
    final Map<String, dynamic> location =
        geoCodeJson['results'][0]['geometry']['location']
            as Map<String, dynamic>;
    return <double>[
      (location['lat'] as num).toDouble(),
      (location['lng'] as num).toDouble(),
    ];
  }

  /// Returns the id of the stored location. `LocationGET` carries an `id` now;
  /// the endpoint used to answer with a bare, always-empty GUID as text.
  Future<String> createLocation(Location location) {
    return _apiClient.post<String>(
      '/api/Location/Add',
      body: location.toJson(),
      parse: (data) => (data as Map<String, dynamic>)['id'] as String,
    );
  }

  Future<Country?> getCountry(String countryId) async {
    try {
      return await _apiClient.get<Country>(
        '/api/Country/Get/$countryId',
        parse: (data) => Country.fromJson(data as Map<String, dynamic>),
      );
    } on UnauthorizedException {
      rethrow;
    } on ApiException {
      // A partner whose stored country no longer exists still has to be able
      // to open their profile and pick a new one.
      return null;
    }
  }
}
