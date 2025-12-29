import 'package:ebooking_desktop/models/country.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ebooking_desktop/config/config.dart' as config;

const String baseApiUrl = "${config.AppConfig.baseUrl}/api";

class CountryHttpService {
  // Add a country
  static Future<void> addCountry(String name) async {
    final response = await http.post(
      Uri.parse('$baseApiUrl/Country/Add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      // Handle the response accordingly
      print("Country added successfully");
    } else {
      // Handle the error
      throw Exception('Failed to add country');
    }
  }

  // Fetch list of countries
  static Future<List<Country>> fetchCountries() async {
    final response = await http.get(Uri.parse('$baseApiUrl/Country/GetCountries'));
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> countriesJson = json.decode(response.body);
      return countriesJson.map((json) => Country.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load countries');
    }
  }

  // Delete a country by ID
  static Future<void> deleteCountry(String countryId) async {
    final response = await http.delete(
      Uri.parse('$baseApiUrl/Country/Delete/$countryId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Handle the response accordingly
      print("Country deleted successfully");
    } else {
      // Handle the error
      throw Exception('Failed to delete country');
    }
  }

  static Future<void> editCountry(String newName, String countryId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseApiUrl/Country/Update'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': countryId,
          'name': newName,

        }),
      );

      if (response.statusCode == 200) {
        // Handle the response accordingly
        print("Country edited successfully");
      } else {
        // Handle the error
        throw Exception('Failed to edit country');
      }
    } catch (e) {
      // Handle or show error
      print('Error editing country: $e');
    }
  }

}