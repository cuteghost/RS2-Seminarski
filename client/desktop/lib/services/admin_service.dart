import 'dart:io';

import 'package:ebooking_desktop/models/accomodation_model.dart';
import 'package:ebooking_desktop/models/profile_model.dart';
import 'package:ebooking_desktop/models/reservation_model.dart';
import 'package:ebooking_desktop/services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ebooking_desktop/config/config.dart' as config;


class AdminService {
  final SecureStorage _secureStorage;
  
  AdminService({required SecureStorage secureStorage}) : _secureStorage = secureStorage;

  getAccommodations() async{
    final token = await _secureStorage.getToken();
    final url = Uri.parse('${config.AppConfig.baseUrl}/api/Administrator/Accommodations');
    return await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    }).then((response) {
      print(response.statusCode);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => AccommodationGET.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load accommodations');
      }
    });
  }

  getProfiles() async {
    final token = await _secureStorage.getToken();
    final url = Uri.parse('${config.AppConfig.baseUrl}/api/Administrator/Customers');
    return await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    }).then((response) async{
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final profiles = await Future.wait(data.map((e) async => Profile.fromJson(e)));
        return profiles;
      } else {
        throw Exception('Failed to load profiles');
      }
    });
  }

  getReservations() async{
    
    final token = await _secureStorage.getToken();
    final url = Uri.parse('${config.AppConfig.baseUrl}/api/Administrator/Reservations?start=${DateTime.now().subtract(Duration(days: 30)).toIso8601String()}&end=${DateTime.now().toIso8601String()}');
    return await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    }).then((response) {
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ReservationGET.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load reservations');
      }
    });
  }

  lowestRents() async{
    final token = await _secureStorage.getToken();
    final url = Uri.parse('${config.AppConfig.baseUrl}/api/Administrator/AccommodationWithLowestRents');
    return await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    }).then((response) {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AccommodationGET.fromJson(data);
      } else {
        throw Exception('Failed to load accommodations');
      }
    });
  }


}