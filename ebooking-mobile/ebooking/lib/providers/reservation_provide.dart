import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/services/reservation_service.dart';
import 'package:flutter/material.dart';

class ReservationProvider with ChangeNotifier
{
  final ReservationService _reservationService;
  ReservationProvider({required ReservationService reservationService}) : _reservationService = reservationService;
  
  List<Map<String,DateTime>> _reservedDates = [];

  List<Map<String,DateTime>> get reservedDates => _reservedDates;


  Future<void> fetchReservedDates(String accommodationId) async {
    _reservedDates = await _reservationService.fetchReservedDates(accommodationId);
    notifyListeners();
  }

  Future<void> makeReservation(ReservationPOST reservation) async {
    await _reservationService.makeReservation(reservation);
    notifyListeners();
  }

  Future<List<ReservationGET>> fetchMyReservations() async {
    return await _reservationService.fetchMyReservations();
  }
}