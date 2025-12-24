import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ebooking/config/config.dart' as config;
import 'package:ebooking/services/auth_service.dart';
import 'package:ebooking/models/accomodation_model.dart';
class AccommodationService {
  final SecureStorage _secureStorage;

  AccommodationService({required SecureStorage secureStorage}) : _secureStorage = secureStorage;

  Future<bool> add(AccommodationPOST accommodation) async {
    final response = await http.post(
        Uri.parse('${config.AppConfig.baseUrl}/api/Accommodation/Add'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await _secureStorage.getToken()}'
        },
        body: json.encode(accommodation.toJson())
        );
        if(response.statusCode == 200) {
          print('Accommodation added successfully');
          return true;
        }
        else {
          print('Failed to add accommodation');
          print (response.body);
          print(response.statusCode);
          return false;
        }

  }

  getMyAccommodations() async {
    final response = await http.get(Uri.parse('${config.AppConfig.baseUrl}/api/Accommodation/GetMyAccommodation'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${await _secureStorage.getToken()}'
    });
    if(response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print(response.body);
      return data.map((json) => AccommodationGET.fromJson(json)).toList();
    }
    else {
      print('Failed to fetch accommodations');
      print(response.body);
      print(response.statusCode);
      return [];
    }
  }

  fetchAccommodation(String accommodationId) async {
    final response = await http.get(Uri.parse('${config.AppConfig.baseUrl}/api/Accommodation/GetAccommodationById?id=$accommodationId'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${await _secureStorage.getToken()}'
    });
    if(response.statusCode == 200) {
      final data = json.decode(response.body);
      return AccommodationGET.fromJson(data);
    }
    else {
      print('Failed to fetch accommodation');
      print(response.body);
      print(response.statusCode);
      return null;
    }
  }

  Future<bool> update(AccommodationPATCH accommodation) async{
    final response = await http.patch(Uri.parse('${config.AppConfig.baseUrl}/api/Accommodation/Update'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${await _secureStorage.getToken()}'
    },
    body: json.encode(accommodation.toJson())
    );
    if(response.statusCode == 200) {
      print('Accommodation updated successfully');
      return true;
    }
    else {
      print('Failed to update accommodation');
      print(response.body);
      print(response.statusCode);
      return false;
    }

  }

  Future<List<AccommodationGET>>fetchNearbyAccommodations(double lat, double long) async {
    // Fetch nearby accommodations based on the latitude and longitude
    print('Latitude: $lat Longitude: $long');
    final response = await http.get(Uri.parse('${config.AppConfig.baseUrl}/api/Accommodation/GetNearby?latitude=$lat&longitude=$long'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${_secureStorage.getToken()}'
    });
    if(response.statusCode == 200) {
      final List<dynamic> accommodationsJson = json.decode(response.body);
      return accommodationsJson.map((json) => AccommodationGET.fromJson(json)).toList();
    }
    else {
      print('Failed to fetch nearby accommodations');
      print(response.body);
      print(response.statusCode);
      List<AccommodationGET> empty = [];
      return empty;
    }
  }
}
