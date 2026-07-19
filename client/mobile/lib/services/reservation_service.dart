import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/services/api_client.dart';

class ReservationService {
  ReservationService({required this._apiClient});

  final ApiClient _apiClient;

  /// Returns the stored reservation. A refusal — an overlapping stay, a date
  /// in the past — arrives as an [ApiException] carrying the server's message.
  Future<ReservationGET> makeReservation(ReservationPOST reservation) {
    return _apiClient.post<ReservationGET>(
      '/api/Reservation/Create',
      body: reservation.toJson(),
      parse: (data) => ReservationGET.fromJson(data as Map<String, dynamic>),
    );
  }

  /// The taken dates for one listing. This endpoint is deliberately not paged
  /// on the server: a partial page would show a booked date as free in the
  /// calendar.
  Future<List<Map<String, DateTime>>> fetchReservedDates(
    String accommodationId,
  ) {
    return _apiClient.get<List<Map<String, DateTime>>>(
      '/api/Reservation/CheckAvailability',
      query: <String, String>{'accommodationId': accommodationId},
      parse: (data) => (data as List)
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => <String, DateTime>{
              'Start': DateTime.parse(item['startDate'] as String),
              'End': DateTime.parse(item['endDate'] as String),
            },
          )
          .toList(),
    );
  }

  /// Every page is walked: the trips screen splits the result into upcoming
  /// and past, so a truncated list would silently drop a stay.
  Future<List<ReservationGET>> fetchMyReservations() {
    return _apiClient.getAllPages<ReservationGET>(
      '/api/Reservation/Customer/GetReservations',
      parseItem: ReservationGET.fromJson,
    );
  }

  Future<List<ReservationGET>> fetchPartnerReservations() {
    return _apiClient.getAllPages<ReservationGET>(
      '/api/Reservation/Partner/GetReservations',
      parseItem: ReservationGET.fromJson,
    );
  }

  Future<ReservationGET> changeStatus(ReservationStatusPATCH change) {
    return _apiClient.patch<ReservationGET>(
      '/api/Reservation/Status',
      body: change.toJson(),
      parse: (data) => ReservationGET.fromJson(data as Map<String, dynamic>),
    );
  }
}
