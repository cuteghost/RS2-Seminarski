import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ebooking_desktop/config/config.dart' as config;
import 'package:ebooking_desktop/models/city.dart';
import 'package:ebooking_desktop/models/country.dart';
import 'package:ebooking_desktop/models/location_model.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/services/auth_service.dart';
import 'package:ebooking_desktop/services/paged.dart';

/// HTTP sloj za referentne podatke lokacije (države i gradovi). Instancna klasa
/// sa `SecureStorage` (isti obrazac kao `AdminService` / `ProfileService`);
/// greške putuju kao `ApiException` sa originalnom serverskom porukom.
class LocationService {
  final SecureStorage _secureStorage;

  LocationService({required SecureStorage secureStorage})
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

  // ── Države ──────────────────────────────────────────────────────────────

  Future<List<Country>> getCountries() {
    return Paged.all<Country>((page, pageSize) async {
      final response = await http.get(
        Uri.parse('$_base/Country/GetCountries?page=$page&pageSize=$pageSize'),
        headers: await _headers(),
      );
      return Paged.read(response, Country.fromJson);
    });
  }

  /// `GET /api/Country/Get/{id}`
  Future<Country> getCountry(String countryId) async {
    final response = await http.get(
      Uri.parse('$_base/Country/Get/$countryId'),
      headers: await _headers(),
    );
    final data = ApiResponseHandler.unwrap(response);
    if (data is! Map<String, dynamic>) {
      throw const ApiException(404, 'Country not found.');
    }
    return Country.fromJson(data);
  }

  /// `POST /api/Country/Add` — vraća poruku o uspjehu koju je server poslao.
  Future<String> addCountry(String name) async {
    final response = await http.post(
      Uri.parse('$_base/Country/Add'),
      headers: await _headers(withBody: true),
      body: jsonEncode({'name': name}),
    );
    return ApiResponseHandler.successMessage(
        response, 'Country successfully added.');
  }

  /// `PATCH /api/Country/Update`
  Future<String> updateCountry({
    required String id,
    required String name,
  }) async {
    final response = await http.patch(
      Uri.parse('$_base/Country/Update'),
      headers: await _headers(withBody: true),
      body: jsonEncode({'id': id, 'name': name}),
    );
    return ApiResponseHandler.successMessage(
        response, 'Country successfully updated.');
  }

  /// `DELETE /api/Country/Delete/{id}`
  ///
  /// Backend `CountryService.DeleteCountry` prvo provjerava da li neki grad
  /// još referencira državu i baca `BusinessException` sa jasnim razlogom.
  /// Ta poruka stiže ovamo kao `ApiException` i prikazuje se doslovno.
  Future<String> deleteCountry(String countryId) async {
    final response = await http.delete(
      Uri.parse('$_base/Country/Delete/$countryId'),
      headers: await _headers(),
    );
    return ApiResponseHandler.successMessage(
        response, 'Country successfully deleted.');
  }

  // ── Gradovi ─────────────────────────────────────────────────────────────

  Future<List<City>> getCities() {
    return Paged.all<City>((page, pageSize) async {
      final response = await http.get(
        Uri.parse('$_base/City/GetCities?page=$page&pageSize=$pageSize'),
        headers: await _headers(),
      );
      return Paged.read(response, City.fromJson);
    });
  }

  Future<List<City>> getCitiesByCountry(String countryId) {
    return Paged.all<City>((page, pageSize) async {
      final response = await http.get(
        Uri.parse(
            '$_base/City/GetCityByCountry/$countryId?page=$page&pageSize=$pageSize'),
        headers: await _headers(),
      );
      return Paged.read(response, City.fromJson);
    });
  }

  /// `POST /api/City/Add`
  Future<String> addCity({
    required String name,
    required String countryId,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/City/Add'),
      headers: await _headers(withBody: true),
      body: jsonEncode({'name': name, 'countryId': countryId}),
    );
    return ApiResponseHandler.successMessage(
        response, 'City successfully added.');
  }

  /// `GET /api/City/Get/{id}`
  Future<City> getCity(String cityId) async {
    final response = await http.get(
      Uri.parse('$_base/City/Get/$cityId'),
      headers: await _headers(),
    );
    final data = ApiResponseHandler.unwrap(response);
    if (data is! Map<String, dynamic>) {
      throw const ApiException(404, 'City not found.');
    }
    return City.fromJson(data);
  }

  /// `PATCH /api/City/Update`
  Future<String> updateCity({
    required String id,
    required String name,
    required String countryId,
  }) async {
    final response = await http.patch(
      Uri.parse('$_base/City/Update'),
      headers: await _headers(withBody: true),
      body: jsonEncode({'id': id, 'name': name, 'countryId': countryId}),
    );
    return ApiResponseHandler.successMessage(
        response, 'City successfully updated.');
  }

  /// `DELETE /api/City/Delete/{id}`
  Future<String> deleteCity(String cityId) async {
    final response = await http.delete(
      Uri.parse('$_base/City/Delete/$cityId'),
      headers: await _headers(),
    );
    return ApiResponseHandler.successMessage(
        response, 'City successfully deleted.');
  }

  // ── Lokacije ────────────────────────────────────────────────────────────

  /// `GET /api/Location/GetLocations?page=&pageSize=`
  Future<List<Location>> getLocations() {
    return Paged.all<Location>((page, pageSize) async {
      final response = await http.get(
        Uri.parse('$_base/Location/GetLocations?page=$page&pageSize=$pageSize'),
        headers: await _headers(),
      );
      return Paged.read(response, Location.fromJson);
    });
  }

  /// `POST /api/Location/Add`
  Future<String> addLocation({
    required String address,
    required double latitude,
    required double longitude,
    required String cityId,
  }) async {
    final response = await http.post(
      Uri.parse('$_base/Location/Add'),
      headers: await _headers(withBody: true),
      body: jsonEncode({
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'cityId': cityId,
      }),
    );
    return ApiResponseHandler.successMessage(
        response, 'Location successfully created.');
  }

  /// `PATCH /api/Location/Update`
  ///
  /// Šalje cijelo stanje lokacije: izostavljena koordinata bi se upisala kao nula.
  Future<String> updateLocation({
    required String id,
    required String address,
    required double latitude,
    required double longitude,
    required String cityId,
  }) async {
    final response = await http.patch(
      Uri.parse('$_base/Location/Update'),
      headers: await _headers(withBody: true),
      body: jsonEncode({
        'id': id,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'cityId': cityId,
      }),
    );
    return ApiResponseHandler.successMessage(
        response, 'Location successfully updated.');
  }

  /// `DELETE /api/Location/Delete/{id}`
  Future<String> deleteLocation(String locationId) async {
    final response = await http.delete(
      Uri.parse('$_base/Location/Delete/$locationId'),
      headers: await _headers(),
    );
    return ApiResponseHandler.successMessage(
        response, 'Location successfully deleted.');
  }
}
