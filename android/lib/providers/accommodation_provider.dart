import 'package:ebooking/services/accommodation_service.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/models/accomodation_model.dart';

class AccommodationProvider with ChangeNotifier {
  final AccommodationService accommodationService;
  AccommodationGET? _accommodation = null; 

  AccommodationProvider({required this.accommodationService});

  void addAccommodation(AccommodationPOST accommodation) {
    accommodationService.add(accommodation);
    notifyListeners();
  }
  Future<List<AccommodationGET>> getMyAccommodations() async {
    return await accommodationService.getMyAccommodations();
  }

  Future<AccommodationGET> fetchAccommodation(String accommodationId) async {
    return await accommodationService.fetchAccommodation(accommodationId);
  }

  Future<bool> updateAccommodation(AccommodationPATCH accommodation) async {
    return accommodationService.update(accommodation);
  }

  Future<List<AccommodationGET>> fetchNearbyAccommodations(double lat, double long) async {
    return await accommodationService.fetchNearbyAccommodations(lat, long);
  }
}
