import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ebooking/config/config.dart';
import 'package:ebooking/models/city_model.dart';

class CityService {
  Future<List<dynamic>> getCities() async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/City/GetCities'));
    if (response.statusCode == 200) {
      final List<dynamic> cityJsonList = json.decode(response.body);
      return cityJsonList.map<City>((json) => City.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cities');
    }
  }
}
