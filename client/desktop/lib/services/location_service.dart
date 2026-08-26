import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ebooking_desktop/config/config.dart' as config;
import 'package:ebooking_desktop/models/city.dart';
import 'package:ebooking_desktop/models/country.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/services/auth_service.dart';

/// HTTP sloj za referentne podatke lokacije (države i gradovi).
///
/// PREPISANO. Stara verzija je imala tri blokirajuća problema:
///
///  1. Bila je `static` klasa bez pristupa tokenu, pa NIJEDAN poziv nije slao
///     `Authorization` header. Otkad `CountryController` ima `[Authorize]` na
///     GET-ovima i `[Authorize(Roles = Roles.Administrator)]` na write
///     operacijama, cijeli ekran je vraćao 401.
///  2. Radila je `json.decode(response.body) as List` — ali golden-template
///     `CountryService` vraća `PagedResponse<CountryGET>`, dakle
///     `{ message, data: [...], page, pageSize, totalCount, totalPages }`.
///     Rezultat: `TypeError` pri svakom učitavanju.
///  3. `editCountry` je imao `try { ... } catch (e) { }` — prazan catch je
///     gutao i mrežne i serverske greške, pa je UI javljao uspjeh i kad
///     server odbije izmjenu (npr. duplikat imena).
///
/// Sada je instancna klasa sa `SecureStorage` (isti obrazac kao
/// `AdminService` / `ProfileService`), a greške putuju kao `ApiException`
/// sa originalnom serverskom porukom.
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

  /// `GET /api/Country/GetCountries?page=&pageSize=`
  ///
  /// Paginacija je obavezna na backendu (Upute 8.2 — `PageSize` je clampovan
  /// na max 100 u `CountryService`). Desktop admin treba kompletnu listu za
  /// dropdownove pa traži maksimum; ako bude više od 100 država, `totalPages`
  /// iz odgovora će to otkriti i tada treba dodati pravu paginaciju u UI.
  Future<({List<Country> items, int totalCount, int totalPages})> getCountries({
    int page = 1,
    int pageSize = 100,
  }) async {
    final response = await http.get(
      Uri.parse('$_base/Country/GetCountries?page=$page&pageSize=$pageSize'),
      headers: await _headers(),
    );

    final body = ApiResponseHandler.decode(response);
    if (body is! Map<String, dynamic>) {
      throw const ApiException(500, 'Neočekivan oblik odgovora za države.');
    }

    final data = body['data'];
    final items = (data is List)
        ? data
            .whereType<Map<String, dynamic>>()
            .map(Country.fromJson)
            .toList()
        : <Country>[];

    return (
      items: items,
      totalCount: (body['totalCount'] as num?)?.toInt() ?? items.length,
      totalPages: (body['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  /// `GET /api/Country/Get/{id}`
  Future<Country> getCountry(String countryId) async {
    final response = await http.get(
      Uri.parse('$_base/Country/Get/$countryId'),
      headers: await _headers(),
    );
    final data = ApiResponseHandler.unwrap(response);
    if (data is! Map<String, dynamic>) {
      throw const ApiException(404, 'Država nije pronađena.');
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
        response, 'Država je uspješno dodana.');
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
        response, 'Država je uspješno izmijenjena.');
  }

  /// `DELETE /api/Country/Delete/{id}`
  ///
  /// Backend `CountryService.DeleteCountry` prvo provjerava da li neki grad
  /// još referencira državu i baca `BusinessException` sa jasnim razlogom
  /// (Upute 3.1 — brisanje mora biti onemogućeno kada zapis koriste drugi
  /// entiteti, uz jasnu poruku). Ta poruka stiže ovamo kao `ApiException`
  /// i prikazuje se doslovno.
  Future<String> deleteCountry(String countryId) async {
    final response = await http.delete(
      Uri.parse('$_base/Country/Delete/$countryId'),
      headers: await _headers(),
    );
    return ApiResponseHandler.successMessage(
        response, 'Država je uspješno obrisana.');
  }

  // ── Gradovi ─────────────────────────────────────────────────────────────

  /// `GET /api/City/GetCities`
  ///
  /// NAPOMENA: `CityController` još nije prošao golden-template refaktor —
  /// nema `[Authorize]`, nema servisni sloj, nema paginaciju i vraća golu
  /// listu (`Json(cities)`) umjesto `BaseResponse`. `unwrapList` zato podnosi
  /// oba oblika, pa se ovaj kod neće morati mijenjati kad refaktor stigne.
  Future<List<City>> getCities() async {
    final response = await http.get(
      Uri.parse('$_base/City/GetCities'),
      headers: await _headers(),
    );
    return ApiResponseHandler.unwrapList(response).map(City.fromJson).toList();
  }

  /// `GET /api/City/GetCityByCountry/{countryId}`
  Future<List<City>> getCitiesByCountry(String countryId) async {
    final response = await http.get(
      Uri.parse('$_base/City/GetCityByCountry/$countryId'),
      headers: await _headers(),
    );
    return ApiResponseHandler.unwrapList(response).map(City.fromJson).toList();
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
        response, 'Grad je uspješno dodan.');
  }
}
