import 'package:ebooking/models/payment_model.dart';
import 'package:ebooking/services/payment_service.dart';
import 'package:flutter/material.dart';

class PaymentProvider with ChangeNotifier {
  PaymentProvider({required this._paymentService});

  final PaymentService _paymentService;

  Future<PaymentGET> fetchForReservation(String reservationId) =>
      _paymentService.fetchForReservation(reservationId);

  Future<Uri> checkoutUri(String reservationId) =>
      _paymentService.checkoutUri(reservationId);

  bool isSuccessUrl(String url) => _paymentService.isSuccessUrl(url);
}
