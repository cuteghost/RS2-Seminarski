import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/providers/reservation_provide.dart';
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

  CheckoutScreen ({required this.numberOfDays, required this.pricePerNight, required this.accommodationId, required this.accommodationName, required this.reservation});
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5));
    return Scaffold(
      appBar: AppBar(
        title: Text('PaymentApp'),
      ),
      body: webview.WebView(
        initialUrl: '',
        javascriptMode: webview.JavascriptMode.unrestricted,
        onWebViewCreated: (webview.WebViewController webViewController) {
          webViewController.loadRequest(webview.WebViewRequest(uri: Uri.parse('${config.AppConfig.paymentUrl}/paypal?numberOfDays=${widget.numberOfDays}&pricePerNight=${widget.pricePerNight}&accommodationId=${widget.accommodationId}&accommodationName=${widget.accommodationName}'), method: webview.WebViewRequestMethod.get));

        },
        onPageFinished: (String url) {
          print('Page finished loading: $url');
          if (url == '${config.AppConfig.paymentUrl}/Paypal/Success') {
            Provider.of<ReservationProvider>(context, listen: false).makeReservation(widget.reservation);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ReservationConfirmationPage(accommodationName: widget.accommodationName)));
          }
        },
      ),
    );
  }
}