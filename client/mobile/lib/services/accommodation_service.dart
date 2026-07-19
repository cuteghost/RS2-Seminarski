import 'dart:typed_data';

import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/services/api_client.dart';

class AccommodationService {
  AccommodationService({required this._apiClient});

  final ApiClient _apiClient;

  /// Returns the stored listing, which the caller needs for its new id.
  Future<AccommodationGET> add(AccommodationPOST accommodation) {
    return _apiClient.post<AccommodationGET>(
      '/api/Accommodation/Add',
      body: accommodation.toJson(),
      parse: (data) => AccommodationGET.fromJson(data as Map<String, dynamic>),
    );
  }

  /// A partner's own listings. Every page is walked: the screen shows total,
  /// active and inactive counts from the complete set, so a partial page
  /// would understate them.
  Future<List<AccommodationGET>> getMyAccommodations() {
    return _apiClient.getAllPages<AccommodationGET>(
      '/api/Accommodation/GetMyAccommodation',
      parseItem: AccommodationGET.fromJson,
    );
  }

  Future<AccommodationGET> fetchAccommodation(String accommodationId) {
    return _apiClient.get<AccommodationGET>(
      '/api/Accommodation/GetAccommodationById',
      query: <String, String>{'id': accommodationId},
      parse: (data) => AccommodationGET.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AccommodationGET> update(AccommodationPATCH accommodation) {
    return _apiClient.patch<AccommodationGET>(
      '/api/Accommodation/Update',
      body: accommodation.toJson(),
      parse: (data) => AccommodationGET.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Uint8List> fetchImage(String imageUrl) {
    return _apiClient.getBytes(imageUrl);
  }

  /// [radiusKm] is the server's own filter radius; it defaults to 10 km there
  /// and is sent explicitly so the value the screen shows is the value asked
  /// for.
  ///
  /// One page, for the previews on the Explore/map screens -- the full list
  /// behind "See all" pages through [fetchNearbyAccommodationsPage] instead.
  Future<List<AccommodationGET>> fetchNearbyAccommodations(
    double latitude,
    double longitude, {
    double radiusKm = 10,
    int pageSize = ApiPagination.maxPageSize,
  }) async {
    final page = await fetchNearbyAccommodationsPage(
      latitude,
      longitude,
      radiusKm: radiusKm,
      pageSize: pageSize,
    );
    return page.items;
  }

  Future<Paged<AccommodationGET>> fetchNearbyAccommodationsPage(
    double latitude,
    double longitude, {
    double radiusKm = 10,
    int page = ApiPagination.firstPage,
    int pageSize = ApiPagination.defaultPageSize,
  }) {
    return _apiClient.getPaged<AccommodationGET>(
      '/api/Accommodation/GetNearby',
      query: <String, String>{
        'latitude': '$latitude',
        'longitude': '$longitude',
        'radius': '$radiusKm',
      },
      parseItem: AccommodationGET.fromJson,
      page: page,
      pageSize: pageSize,
    );
  }
}
