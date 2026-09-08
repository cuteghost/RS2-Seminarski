import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/reservation_model.dart';
import 'package:ebooking/providers/payment_provider.dart';
import 'package:ebooking/providers/reservation_provider.dart';
import 'package:ebooking/screens/customer_screens/reservation_confirmation_screen.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;

enum _Stage { preparing, paying, checking, stopped }

class CheckoutScreen extends StatefulWidget {
  final ReservationPOST? reservation;
  final String? reservationId;
  final String accommodationName;

  const CheckoutScreen.forNewBooking({
    super.key,
    required ReservationPOST this.reservation,
    required this.accommodationName,
  }) : reservationId = null;

  const CheckoutScreen.forExistingBooking({
    super.key,
    required String this.reservationId,
    required this.accommodationName,
  }) : reservation = null;

  @override
  CheckoutScreenState createState() => CheckoutScreenState();
}

class CheckoutScreenState extends State<CheckoutScreen> {
  webview.WebViewController? _webViewController;
  _Stage _stage = _Stage.preparing;
  String? _reservationId;
  String? _message;
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final attempt = ++_attempt;

    setState(() {
      _stage = _Stage.preparing;
      _message = null;
      _webViewController = null;
    });

    try {
      final reservationId =
          _reservationId ??
          widget.reservationId ??
          (await Provider.of<ReservationProvider>(
            context,
            listen: false,
          ).makeReservation(widget.reservation!)).id;
      if (!mounted || attempt != _attempt) return;

      final payment = Provider.of<PaymentProvider>(context, listen: false);
      final uri = await payment.checkoutUri(reservationId);
      if (!mounted || attempt != _attempt) return;

      var documentUrl = uri.toString();

      final controller = webview.WebViewController()
        ..setJavaScriptMode(webview.JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          webview.NavigationDelegate(
            onPageStarted: (url) => documentUrl = url,
            onPageFinished: (url) {
              if (!mounted || attempt != _attempt) return;
              if (!payment.isSuccessUrl(url)) return;
              _verify();
            },
            onWebResourceError: (error) {
              if (error.isForMainFrame == false) return;
              _stopPaying(
                attempt,
                'The payment page could not be opened: ${error.description}. '
                'Check that you are online and that the payment service is '
                'running, then try again.',
              );
            },
            onHttpError: (error) {
              final failed = error.request?.uri.toString();
              if (failed == null || failed != documentUrl) return;

              final status = error.response?.statusCode;
              _stopPaying(
                attempt,
                status == 401 || status == 403
                    ? 'This payment session is no longer valid. Start the '
                          'payment again.'
                    : 'The payment service could not open the checkout page'
                          '${status == null ? '' : ' ($status)'}. '
                          'Please try again.',
              );
            },
          ),
        )
        ..loadRequest(uri);

      setState(() {
        _reservationId = reservationId;
        _webViewController = controller;
        _stage = _Stage.paying;
      });
    } on ApiException catch (e) {
      _stop(attempt, e.message);
    } catch (_) {
      _stop(attempt, 'The payment could not be started. Please try again.');
    }
  }

  void _stop(int attempt, String message) {
    if (!mounted || attempt != _attempt) return;
    setState(() {
      _stage = _Stage.stopped;
      _message = message;
    });
  }

  void _stopPaying(int attempt, String message) {
    if (_stage != _Stage.paying) return;
    _stop(attempt, message);
  }

  Future<void> _verify() async {
    final reservationId = _reservationId;
    if (reservationId == null) return;

    final attempt = _attempt;
    setState(() => _stage = _Stage.checking);

    try {
      final payment = await Provider.of<PaymentProvider>(
        context,
        listen: false,
      ).fetchForReservation(reservationId);
      if (!mounted || attempt != _attempt) return;

      if (payment.isPaid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ReservationConfirmationPage(
              accommodationName: widget.accommodationName,
            ),
          ),
        );
        return;
      }

      _stop(
        attempt,
        'The server has no completed payment for this booking. Your booking is held under Trips and can be paid from there.',
      );
    } on ApiException catch (e) {
      _stop(attempt, e.message);
    } catch (_) {
      _stop(
        attempt,
        'The payment could not be confirmed with the server. Your booking is held under Trips and can be paid from there.',
      );
    }
  }

  @override
  void dispose() {
    _webViewController?.setNavigationDelegate(webview.NavigationDelegate());
    super.dispose();
  }

  Widget _busy(String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _stopped() {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _message ?? 'The payment could not be started.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            OutlinedButton(onPressed: _start, child: const Text('Try again')),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Pay with PayPal')),
      body: switch (_stage) {
        _Stage.preparing => _busy('Holding your booking...'),
        _Stage.checking => _busy('Checking the payment with the server...'),
        _Stage.paying => webview.WebViewWidget(controller: _webViewController!),
        _Stage.stopped => _stopped(),
      },
    );
  }
}
