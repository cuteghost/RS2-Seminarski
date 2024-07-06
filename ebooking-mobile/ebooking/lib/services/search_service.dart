import 'dart:convert';

import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:ebooking/config/config.dart';


class SearchService {
  final SecureStorage _secureStorage;
  
  SearchService({required SecureStorage secureStorage}) : _secureStorage = secureStorage;
  
  Future<List<AccommodationGET>> search(double priceFrom, double priceTo, String city, DateTime checkIn, DateTime checkOut) async {
    final token = await _secureStorage.getToken();
    final response = await http.get(
                    Uri.parse('${AppConfig.baseUrl}/api/Search?priceFrom=$priceFrom&priceTo=$priceTo&city=$city&checkIn=$checkIn&checkOut=$checkOut'), 
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Accept': 'application/json'
                      });
    print(response.statusCode);
    if (response.statusCode != 200) {
      throw Exception('Failed to search accomodation');
    }
    else {
      return List<AccommodationGET>.from(json.decode(response.body).map((x) => AccommodationGET.fromJson(x)));
    }
  }
}