import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'firestore_service.dart';

class PaymentService {
  static const String _backendUrl = 'https://ai-tutor-backend.atharv-robotics.workers.dev';

  static const int monthlyPriceInPaise = 9900; // ?99
  static const int yearlyPriceInPaise = 79900; // ?799

  static const String razorpayKeyId = 'rzp_test_TAANwmGF7Byn8W';

  static late Razorpay _razorpay;
  static Function(String plan)? _onSuccessCallback;
  static Function(String error)? _onErrorCallback;

  static void init() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  static void dispose() {
    _razorpay.clear();
  }

  static Future<void> startCheckout({
    required String plan,
    required Function(String plan) onSuccess,
    required Function(String error) onError,
  }) async {
    _onSuccessCallback = onSuccess;
    _onErrorCallback = onError;

    final amount = plan == 'yearly' ? yearlyPriceInPaise : monthlyPriceInPaise;

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': amount, 'plan': plan}),
      );
      final orderData = jsonDecode(response.body);

      if (orderData['id'] == null) {
        onError('Could not create payment order.');
        return;
      }

      final options = {
        'key': razorpayKeyId,
        'amount': amount,
        'currency': 'INR',
        'name': 'One Robotics Ai',
        'description': plan == 'yearly' ? 'Yearly Premium Subscription' : 'Monthly Premium Subscription',
        'order_id': orderData['id'],
        'prefill': {'contact': '', 'email': ''},
        'notes': {'plan': plan},
      };

      _pendingPlan = plan;
      _razorpay.open(options);
    } catch (e) {
      onError('Something went wrong: $e');
    }
  }

  static String? _pendingPlan;

  static Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final verifyResponse = await http.post(
        Uri.parse('$_backendUrl/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'razorpay_order_id': response.orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
        }),
      );
      final verifyData = jsonDecode(verifyResponse.body);

      if (verifyData['verified'] == true) {
        final plan = _pendingPlan ?? 'monthly';
        await FirestoreService.activateSubscription(plan);
        _onSuccessCallback?.call(plan);
      } else {
        _onErrorCallback?.call('Payment could not be verified. Please contact support.');
      }
    } catch (e) {
      _onErrorCallback?.call('Verification failed: $e');
    }
  }

  static void _handlePaymentError(PaymentFailureResponse response) {
    _onErrorCallback?.call(response.message ?? 'Payment failed or was cancelled.');
  }

  static void _handleExternalWallet(ExternalWalletResponse response) {}
}
