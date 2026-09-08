import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ebooking_desktop/config/config.dart' as config;
import 'package:ebooking_desktop/models/accommodation_type.dart';
import 'package:ebooking_desktop/models/amenity.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/services/auth_service.dart';
import 'package:ebooking_desktop/services/paged.dart';

class ReferenceDataService {
  final SecureStorage _secureStorage;

  ReferenceDataService({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  String get _base => '${config.AppConfig.baseUrl}/api';

  Future<Map<String, String>> _headers({bool withBody = false}) async {
    final token = await _secureStorage.getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      if (withBody) 'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  Future<List<AccommodationType>> getTypes() {
    return Paged.all<AccommodationType>((page, pageSize) async {
      final response = await http.get(
        Uri.parse('$_base/AccommodationType/GetTypes'
            '?page=$page&pageSize=$pageSize'),
        headers: await _headers(),
      );
      return Paged.read(response, AccommodationType.fromJson);
    });
  }

  Future<AccommodationType> getType(String id) async {
    final response = await http.get(
      Uri.parse('$_base/AccommodationType/Get/$id'),
      headers: await _headers(),
    );
    final data = ApiResponseHandler.unwrap(response);
    if (data is! Map<String, dynamic>) {
      throw const ApiException(404, 'Property type not found.');
    }
    return AccommodationType.fromJson(data);
  }

  Future<String> addType({required String name, required int sortOrder}) async {
    final response = await http.post(
      Uri.parse('$_base/AccommodationType/Add'),
      headers: await _headers(withBody: true),
      body: jsonEncode({'name': name, 'sortOrder': sortOrder}),
    );
    return ApiResponseHandler.successMessage(
        response, 'Property type successfully added.');
  }

  Future<String> updateType({
    required String id,
    required String name,
    required int sortOrder,
  }) async {
    final response = await http.patch(
      Uri.parse('$_base/AccommodationType/Update'),
      headers: await _headers(withBody: true),
      body: jsonEncode({'id': id, 'name': name, 'sortOrder': sortOrder}),
    );
    return ApiResponseHandler.successMessage(
        response, 'Property type successfully updated.');
  }

  Future<String> deleteType(String id) async {
    final response = await http.delete(
      Uri.parse('$_base/AccommodationType/Delete/$id'),
      headers: await _headers(),
    );
    return ApiResponseHandler.successMessage(
        response, 'Property type successfully deleted.');
  }

  Future<List<Amenity>> getAmenities() {
    return Paged.all<Amenity>((page, pageSize) async {
      final response = await http.get(
        Uri.parse('$_base/Amenity/GetAmenities?page=$page&pageSize=$pageSize'),
        headers: await _headers(),
      );
      return Paged.read(response, Amenity.fromJson);
    });
  }

  Future<Amenity> getAmenity(String id) async {
    final response = await http.get(
      Uri.parse('$_base/Amenity/Get/$id'),
      headers: await _headers(),
    );
    final data = ApiResponseHandler.unwrap(response);
    if (data is! Map<String, dynamic>) {
      throw const ApiException(404, 'Amenity not found.');
    }
    return Amenity.fromJson(data);
  }

  Future<String> addAmenity({
    required String code,
    required String name,
    required int sortOrder,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/Amenity/Add'),
      headers: await _headers(withBody: true),
      body: jsonEncode({'code': code, 'name': name, 'sortOrder': sortOrder}),
    );
    return ApiResponseHandler.successMessage(
        response, 'Amenity successfully added.');
  }

  Future<String> updateAmenity({
    required String id,
    required String code,
    required String name,
    required int sortOrder,
  }) async {
    final response = await http.patch(
      Uri.parse('$_base/Amenity/Update'),
      headers: await _headers(withBody: true),
      body: jsonEncode(
          {'id': id, 'code': code, 'name': name, 'sortOrder': sortOrder}),
    );
    return ApiResponseHandler.successMessage(
        response, 'Amenity successfully updated.');
  }

  Future<String> deleteAmenity(String id) async {
    final response = await http.delete(
      Uri.parse('$_base/Amenity/Delete/$id'),
      headers: await _headers(),
    );
    return ApiResponseHandler.successMessage(
        response, 'Amenity successfully deleted.');
  }
}
