import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../api/api_client.dart'; // your existing API client

class PaymentService {
  final Razorpay _razorpay = Razorpay();

  void init() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> createOrderAndPay(int amount) async {
    // 1️⃣ Create Razorpay order via backend
    final response = await ApiClient.post(
      '/payment/create-order',
      body: {'amount': amount},
    );

    final json = ApiClient.handleResponse(response);
    final order = json['data']['order'];
    final orderId = order['id'] as String;

    // 2️⃣ Open Razorpay popup
    var options = {
      'key': 'rzp_test_RiykKYRYFMVqNR', // ⚠️ USE ONLY KEY_ID (not secret)
      'amount': amount * 100,
      'name': 'eGrocery',
      'order_id': orderId,
      'prefill': {
        'name': 'Test User',
        'email': 'test@gmail.com',
        'contact': '9999999999'
      },
    };

    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('PAYMENT SUCCESS: ${response.paymentId}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('PAYMENT ERROR: ${response.code} | ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('EXTERNAL WALLET: ${response.walletName}');
  }

  void dispose() {
    _razorpay.clear();
  }
}
