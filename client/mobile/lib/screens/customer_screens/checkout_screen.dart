import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/providers/reservation_provider.dart';
import 'package:ebooking/screens/customer_screens/reservation_confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import 'package:ebooking/config/config.dart' as config;

class CheckoutScreen extends StatefulWidget {
  final int numberOfDays;
  final double pricePerNight;
  final String accommodationId;
  final String accommodationName;
  final ReservationPOST reservation;

  const CheckoutScreen({
    super.key,
    required this.numberOfDays,
    required this.pricePerNight,
    required this.accommodationId,
    required this.accommodationName,
    required this.reservation,
  });

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  late final webview.WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    // webview_flutter 4.x replaced the declarative WebView widget with a
    // controller built up front and rendered via WebViewWidget. The request
    // is a GET, which is loadRequest's default.
    _webViewController = webview.WebViewController()
      ..setJavaScriptMode(webview.JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        webview.NavigationDelegate(
          onPageFinished: (String url) {
            if (!mounted) return;
            if (url == '${config.AppConfig.paymentUrl}/Paypal/Success') {
              Provider.of<ReservationProvider>(context, listen: false)
                  .makeReservation(widget.reservation);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReservationConfirmationPage(
                          accommodationName: widget.accommodationName)));
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(
          '${config.AppConfig.paymentUrl}/paypal?numberOfDays=${widget.numberOfDays}&pricePerNight=${widget.pricePerNight}&accommodationId=${widget.accommodationId}&accommodationName=${widget.accommodationName}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PaymentApp'),
      ),
      body: webview.WebViewWidget(controller: _webViewController),
    );
  }
}
