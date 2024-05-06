import 'package:ebooking/models/accomodation_model.dart';
import 'package:ebooking/services/auth_service.dart';
import 'dart:io';

import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ebooking/config/config.dart' as config;
class AccommodationService {
  final SecureStorage _secureStorage;

  AccommodationService({required SecureStorage secureStorage}) : _secureStorage = secureStorage;

  Future<bool> add(Accommodation accommodation) async {
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
}
