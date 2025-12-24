import 'package:ebooking_desktop/models/accomodation_model.dart';
import 'package:ebooking_desktop/models/profile_model.dart';
import 'package:ebooking_desktop/models/reservation_model.dart';
import 'package:ebooking_desktop/services/admin_service.dart';
import 'package:flutter/material.dart';

class AdminProvider with ChangeNotifier {
  final AdminService adminService;

  List<AccommodationGET> _accommodations = [];
  List<Profile> _profiles = [];
  List<ReservationGET> _reservations = [];

  List<AccommodationGET> get accommodations => _accommodations;
  List<Profile> get profiles => _profiles;
  List<ReservationGET> get reservations => _reservations;

  AdminProvider({required this.adminService});

  Future<void> getAccommodations() async {
    _accommodations = await adminService.getAccommodations();
    notifyListeners();
  }

  Future<void> getProfiles() async {
    _profiles = await adminService.getProfiles();
    notifyListeners();
  }

  Future<void> getReservations() async {
    _reservations = await adminService.getReservations();
    notifyListeners();
  }

  AccommodationGET getLowestRent() {
    _accommodations.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
    return _accommodations.first;
  }

  AccommodationGET getHighestRent() {

    _accommodations.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
    return _accommodations.first;
  }


}