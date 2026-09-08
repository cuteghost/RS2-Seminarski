import 'package:ebooking/config/config.dart';
import 'package:ebooking/models/payment_model.dart';
import 'package:ebooking/services/api_client.dart';

class PaymentService {
  PaymentService({required this._apiClient});

  final ApiClient _apiClient;

  Future<PaymentGET> fetchForReservation(String reservationId) {
    return _apiClient.get<PaymentGET>(
      '/api/Payment/ByReservation/$reservationId',
      parse: (data) => PaymentGET.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Uri> checkoutUri(String reservationId) async {
    final ticket = await _apiClient.post<String>(
      '/api/Payment/Ticket/$reservationId',
      parse: (data) => data as String,
    );
    return Uri.parse('${AppConfig.paymentUrl}/Paypal/Index').replace(
      queryParameters: <String, String>{
        'reservationId': reservationId,
        'token': ticket,
      },
    );
  }

  bool isSuccessUrl(String url) =>
      url.startsWith('${AppConfig.paymentUrl}/Paypal/Success');
}
