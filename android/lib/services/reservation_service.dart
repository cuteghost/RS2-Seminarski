import 'dart:convert';

import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:ebooking/config/config.dart';


class ReservationService {
  final SecureStorage _secureStorage;
  
  ReservationService({required SecureStorage secureStorage}) : _secureStorage = secureStorage;
  
  Future<void> makeReservation(ReservationPOST reservation) async {
    final token = await _secureStorage.getToken();
    final response = await http.post(Uri.parse('${AppConfig.baseUrl}/api/Reservation/Create'), 
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json'
                      },
                      body: json.encode(reservation.toJson()));
    if (response.statusCode != 200) {
      throw Exception('Failed to make reservation');
    }
    else {
      return;
    }
  }
  Future<List<Map<String,DateTime>>> fetchReservedDates(String accommodationId) async {
    final token = await _secureStorage.getToken();
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/Reservation/CheckAvailability?accommodationId=$accommodationId'), 
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Accept': 'application/json'
                      });
    if (response.statusCode == 200) {
      final List<dynamic> reservedDatesJsonList = json.decode(response.body);
      return reservedDatesJsonList.map((item) => {
        'Start': DateTime.parse(item['startDate']),
        'End': DateTime.parse(item['endDate'])
      }).toList();
    } else {
      throw Exception('Failed to load reserved dates');
    }
  }

  Future<List<ReservationGET>> fetchMyReservations() async {
    final token = await _secureStorage.getToken();
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/Reservation/Customer/GetReservations'), 
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Accept': 'application/json'
                    });
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> reservationsJsonList = json.decode(response.body);
      print(reservationsJsonList);
      return reservationsJsonList.map((item) => ReservationGET.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load my reservations');
    }
  }
}