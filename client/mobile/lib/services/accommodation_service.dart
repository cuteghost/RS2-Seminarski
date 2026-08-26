import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ebooking/config/config.dart' as config;
import 'package:ebooking/services/auth_service.dart';
import 'package:ebooking/models/accomodation_model.dart';

class AccommodationService {
  final SecureStorage _secureStorage;

  AccommodationService({required this._secureStorage});

  Future<bool> add(AccommodationPOST accommodation) async {
    final response = await http.post(
        Uri.parse('${config.AppConfig.baseUrl}/api/Accommodation/Add'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _secureStorage.getToken()}'
        },
        body: json.encode(accommodation.toJson()));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<AccommodationGET>> getMyAccommodations() async {
    final response = await http.get(
        Uri.parse(
            '${config.AppConfig.baseUrl}/api/Accommodation/GetMyAccommodation'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _secureStorage.getToken()}'
        });
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AccommodationGET.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<AccommodationGET> fetchAccommodation(String accommodationId) async {
    final response = await http.get(
        Uri.parse(
            '${config.AppConfig.baseUrl}/api/Accommodation/GetAccommodationById?id=$accommodationId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _secureStorage.getToken()}'
        });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AccommodationGET.fromJson(data);
    } else {
      throw Exception('Failed to fetch accommodation');
    }
  }

  Future<bool> update(AccommodationPATCH accommodation) async {
    final response = await http.patch(
        Uri.parse('${config.AppConfig.baseUrl}/api/Accommodation/Update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _secureStorage.getToken()}'
        },
        body: json.encode(accommodation.toJson()));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<AccommodationGET>> fetchNearbyAccommodations(
      double lat, double long) async {
    // Fetch nearby accommodations based on the latitude and longitude
    final response = await http.get(
        Uri.parse(
            '${config.AppConfig.baseUrl}/api/Accommodation/GetNearby?latitude=$lat&longitude=$long'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${_secureStorage.getToken()}'
        });
    if (response.statusCode == 200) {
      final List<dynamic> accommodationsJson = json.decode(response.body);
      return accommodationsJson
          .map((json) => AccommodationGET.fromJson(json))
          .toList();
    } else {
      List<AccommodationGET> empty = [];
      return empty;
    }
  }
}
