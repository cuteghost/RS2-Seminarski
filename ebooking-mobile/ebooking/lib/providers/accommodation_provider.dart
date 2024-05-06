import 'package:ebooking/services/accommodation_service.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/models/accomodation_model.dart';

class AccommodationProvider with ChangeNotifier {
  final AccommodationService accommodationService;

  AccommodationProvider({required this.accommodationService});

  void addAccommodation(Accommodation accommodation) {
    accommodationService.add(accommodation);
    notifyListeners();
  }
}
