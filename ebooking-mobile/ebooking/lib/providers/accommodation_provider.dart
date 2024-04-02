import 'package:flutter/material.dart';
import 'package:ebooking/models/accomodation_model.dart';

class AccommodationProvider with ChangeNotifier {
  // List of accommodations or any other data you want to manage
  List<Accommodation> _accommodations = [];

  List<Accommodation> get accommodations => _accommodations;

  // Add methods to modify the accommodations list, like addAccommodation, updateAccommodation, etc.
  void addAccommodation(Accommodation accommodation) {
    _accommodations.add(accommodation);
    notifyListeners();
  }
}
