import '../../constants/app_constants.dart';
import '../api_client.dart';
import '../models/api_response.dart';

class PaymentApiService {
  /// Create Razorpay order on backend
  static Future<ApiResponse<RazorpayOrderResponse>> createRazorpayOrder({
    required double amount,
  }) async {
    final response = await ApiClient.post(
      '/payment/create-order',
      body: {
        'amount': amount,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => RazorpayOrderResponse.fromJson(data as Map<String, dynamic>),
    );
  }
}

class RazorpayOrderResponse {
  final RazorpayOrder order;

  RazorpayOrderResponse({required this.order});

  factory RazorpayOrderResponse.fromJson(Map<String, dynamic> json) {
    return RazorpayOrderResponse(
      order: RazorpayOrder.fromJson(json['order'] as Map<String, dynamic>),
    );
  }
}

class RazorpayOrder {
  final String id;
  final String entity;
  final int amount;
  final int amountPaid;
  final int amountDue;
  final String currency;
  final String receipt;
  final String status;
  final int attempts;
  final int createdAt;

  RazorpayOrder({
    required this.id,
    required this.entity,
    required this.amount,
    required this.amountPaid,
    required this.amountDue,
    required this.currency,
    required this.receipt,
    required this.status,
    required this.attempts,
    required this.createdAt,
  });

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) {
    return RazorpayOrder(
      id: json['id'] ?? '',
      entity: json['entity'] ?? 'order',
      amount: json['amount'] ?? 0,
      amountPaid: json['amount_paid'] ?? 0,
      amountDue: json['amount_due'] ?? 0,
      currency: json['currency'] ?? 'INR',
      receipt: json['receipt'] ?? '',
      status: json['status'] ?? 'created',
      attempts: json['attempts'] ?? 0,
      createdAt: json['created_at'] ?? 0,
    );
  }
}
