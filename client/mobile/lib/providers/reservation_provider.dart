import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/services/reservation_service.dart';
import 'package:flutter/material.dart';

class ReservationProvider with ChangeNotifier {
  final ReservationService _reservationService;
  ReservationProvider({required this._reservationService});

  List<Map<String, DateTime>> _reservedDates = [];

  List<Map<String, DateTime>> get reservedDates => _reservedDates;

  Future<void> fetchReservedDates(String accommodationId) async {
    _reservedDates = await _reservationService.fetchReservedDates(
      accommodationId,
    );
    notifyListeners();
  }

  /// Returns the stored reservation; a refusal (an overlapping stay, a date
  /// in the past) arrives as an ApiException carrying the server's message.
  Future<ReservationGET> makeReservation(ReservationPOST reservation) async {
    final created = await _reservationService.makeReservation(reservation);
    notifyListeners();
    return created;
  }

  Future<List<ReservationGET>> fetchMyReservations() async {
    return await _reservationService.fetchMyReservations();
  }

  Future<List<ReservationGET>> fetchPartnerReservations() async {
    return await _reservationService.fetchPartnerReservations();
  }

  Future<ReservationGET> cancelReservation(
    String reservationId, {
    String? reason,
  }) {
    return _changeStatus(reservationId, ReservationStatus.cancelled, reason);
  }

  Future<ReservationGET> confirmReservation(String reservationId) {
    return _changeStatus(reservationId, ReservationStatus.confirmed, null);
  }

  Future<ReservationGET> rejectReservation(
    String reservationId, {
    required String reason,
  }) {
    return _changeStatus(reservationId, ReservationStatus.rejected, reason);
  }

  Future<ReservationGET> completeReservation(String reservationId) {
    return _changeStatus(reservationId, ReservationStatus.completed, null);
  }

  Future<ReservationGET> _changeStatus(
    String reservationId,
    ReservationStatus status,
    String? reason,
  ) async {
    final updated = await _reservationService.changeStatus(
      ReservationStatusPATCH(
        reservationId: reservationId,
        status: status,
        reason: reason,
      ),
    );
    notifyListeners();
    return updated;
  }
}
