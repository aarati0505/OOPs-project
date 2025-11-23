import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../constants/payment_constants.dart';
import '../constants/app_constants.dart';

/// Payment Service for handling Razorpay payments
class PaymentService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onFailure;
  Function()? _onDismiss;

  /// Initialize Razorpay
  void initialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    Function()? onDismiss,
  }) {
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    _onDismiss = onDismiss;

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Open Razorpay checkout
  void openCheckout({
    required double amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) {
    // Check if Razorpay is configured
    if (!PaymentConstants.isConfigured) {
      print('❌ Razorpay not configured! Please add your API keys.');
      if (_onFailure != null) {
        _onFailure!(PaymentFailureResponse(
          0,
          'Razorpay not configured',
          null,
        ));
      }
      return;
    }

    final options = PaymentConstants.getPaymentOptions(
      amount: amount,
      orderId: orderId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
    );

    try {
      _razorpay.open(options);
      print('✅ Razorpay checkout opened');
    } catch (e) {
      print('❌ Error opening Razorpay: $e');
      if (_onFailure != null) {
        _onFailure!(PaymentFailureResponse(
          0,
          e.toString(),
          null,
        ));
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('✅ Payment Success!');
    print('   Payment ID: ${response.paymentId}');
    print('   Order ID: ${response.orderId}');
    print('   Signature: ${response.signature}');
    
    if (_onSuccess != null) {
      _onSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('❌ Payment Failed!');
    print('   Code: ${response.code}');
    print('   Message: ${response.message}');
    
    if (_onFailure != null) {
      _onFailure!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('💳 External Wallet: ${response.walletName}');
  }

  /// Dispose Razorpay instance
  void dispose() {
    _razorpay.clear();
  }

  /// Create order on backend (call this before opening checkout)
  /// This calls your backend API to create a Razorpay order
  static Future<String?> createOrderOnBackend({
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/payment/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final orderId = data['data']?['order']?['id'];
        
        if (orderId != null) {
          print('✅ Razorpay order created: $orderId');
          return orderId;
        }
      }

      print('❌ Failed to create order: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    } catch (e) {
      print('❌ Error creating order: $e');
      return null;
    }
  }
}
