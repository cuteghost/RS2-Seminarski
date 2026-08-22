import 'dart:convert';
import 'package:ebooking/models/city_model.dart';
import 'package:ebooking/models/country_model.dart';
import 'package:ebooking/models/location_model.dart';
import 'package:http/http.dart' as http;
import 'package:ebooking/config/config.dart';
import 'package:ebooking/services/auth_service.dart';

class LocationService {
  final SecureStorage _secureStorage;

  LocationService({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  Future<List<Country>> getCountries() async {
    final token = await _secureStorage.getToken();
    final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/Country/GetCountries'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      // Backend now wraps list responses: { message, data: [...], page, pageSize, totalCount, totalPages }
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> countryJsonList = decoded['data'] ?? [];
      return countryJsonList.map((item) => Country.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load countries');
    }
  }

  // NOTE: /api/City/GetCityByCountry is not implemented on the backend yet.
  // City is next in line for the golden-template rollout — this stays broken until then.
  Future<List<City>> getCities(String? countryId) async {
    if (countryId == null) {
      throw Exception('Country ID is null');
    }
    final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/City/GetCityByCountry/$countryId'));
    if (response.statusCode == 200) {
      final List<dynamic> cityJsonList = json.decode(response.body);
      return cityJsonList.map((item) => City.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load cities');
    }
  }

  Future<List<double>> geoCode(String geoCodeInfo) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(geoCodeInfo)}&key=${AppConfig.googleApiKey}'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> geoCodeJson = json.decode(response.body);
      if (geoCodeJson['status'] == 'OK') {
        final Map<String, dynamic> location =
            geoCodeJson['results'][0]['geometry']['location'];
        return [location['lat'], location['lng']];
      } else {
        throw Exception('Failed to get geo code');
      }
    } else {
      throw Exception('Failed to get geo code');
    }
  }

  Future<String> createLocation(Location location) async {
    final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/Location/Add'),
        body: json.encode(location.toJson()),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to create location');
    }
  }

  Future<Country?> getCountry(String countryId) async {
    final token = await _secureStorage.getToken();
    final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/Country/Get/$countryId'),
        headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      // Backend now wraps single-item responses: { message, data: {...} }
      final Map<String, dynamic> decoded = json.decode(response.body);
      return Country.fromJson(decoded['data']);
    } else {
      return null;
    }
  }
}
