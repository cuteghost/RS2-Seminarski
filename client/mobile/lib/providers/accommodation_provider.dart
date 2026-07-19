import 'dart:typed_data';

import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/services/accommodation_service.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:flutter/material.dart';

class AccommodationProvider with ChangeNotifier {
  final AccommodationService accommodationService;

  AccommodationProvider({required this.accommodationService});

  /// Returns the stored listing and throws [ApiException] when the server
  /// refuses it. The old `void` version dropped both, so the screen moved on
  /// as if the listing had been created.
  Future<AccommodationGET> addAccommodation(
    AccommodationPOST accommodation,
  ) async {
    final added = await accommodationService.add(accommodation);
    notifyListeners();
    return added;
  }

  Future<List<AccommodationGET>> getMyAccommodations() {
    return accommodationService.getMyAccommodations();
  }

  Future<AccommodationGET> fetchAccommodation(String accommodationId) {
    return accommodationService.fetchAccommodation(accommodationId);
  }

  Future<AccommodationGET> updateAccommodation(
    AccommodationPATCH accommodation,
  ) async {
    final updated = await accommodationService.update(accommodation);
    notifyListeners();
    return updated;
  }

  Future<Uint8List> fetchImage(String imageUrl) {
    return accommodationService.fetchImage(imageUrl);
  }

  Future<List<AccommodationGET>> fetchNearbyAccommodations(
    double lat,
    double long, {
    int pageSize = ApiPagination.maxPageSize,
  }) {
    return accommodationService.fetchNearbyAccommodations(
      lat,
      long,
      pageSize: pageSize,
    );
  }

  Future<Paged<AccommodationGET>> fetchNearbyAccommodationsPage(
    double lat,
    double long, {
    int page = ApiPagination.firstPage,
  }) {
    return accommodationService.fetchNearbyAccommodationsPage(
      lat,
      long,
      page: page,
    );
  }
}
