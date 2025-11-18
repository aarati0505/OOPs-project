import '../../constants/app_constants.dart';
import '../../models/order_model.dart';
import '../api_client.dart';
import '../models/api_response.dart';

class OrderApiService {
  // Create order (Customer)
  static Future<ApiResponse<OrderModel>> createOrder({
    required String token,
    required CreateOrderRequest request,
  }) async {
    final response = await ApiClient.post(
      AppConstants.createOrderEndpoint,
      token: token,
      body: request.toJson(),
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => OrderModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // Get customer orders
  static Future<PaginatedResponse<OrderModel>> getCustomerOrders({
    required String token,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status,
    };

    final response = await ApiClient.get(
      AppConstants.ordersEndpoint,
      token: token,
      queryParameters: queryParams,
    );

    final json = ApiClient.handleResponse(response);
    return PaginatedResponse.fromJson(
      json['data'] as Map<String, dynamic>,
      (item) => OrderModel.fromJson(item as Map<String, dynamic>),
    );
  }

  // Get order by ID
  static Future<ApiResponse<OrderModel>> getOrderById({
    required String token,
    required String orderId,
  }) async {
    final response = await ApiClient.get(
      '${AppConstants.orderDetailEndpoint}/$orderId',
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => OrderModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // Get retailer orders (from customers)
  static Future<PaginatedResponse<OrderModel>> getRetailerCustomerOrders({
    required String token,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status,
    };

    final response = await ApiClient.get(
      AppConstants.customerOrdersEndpoint,
      token: token,
      queryParameters: queryParams,
    );

    final json = ApiClient.handleResponse(response);
    return PaginatedResponse.fromJson(
      json['data'] as Map<String, dynamic>,
      (item) => OrderModel.fromJson(item as Map<String, dynamic>),
    );
  }

  // Get retailer orders (from wholesalers)
  static Future<PaginatedResponse<OrderModel>> getRetailerWholesalerOrders({
    required String token,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status,
    };

    final response = await ApiClient.get(
      AppConstants.wholesalerOrdersEndpoint,
      token: token,
      queryParameters: queryParams,
    );

    final json = ApiClient.handleResponse(response);
    return PaginatedResponse.fromJson(
      json['data'] as Map<String, dynamic>,
      (item) => OrderModel.fromJson(item as Map<String, dynamic>),
    );
  }

  // Get wholesaler orders (from retailers)
  static Future<PaginatedResponse<OrderModel>> getWholesalerRetailerOrders({
    required String token,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status,
    };

    final response = await ApiClient.get(
      AppConstants.wholesalerRetailerOrdersEndpoint,
      token: token,
      queryParameters: queryParams,
    );

    final json = ApiClient.handleResponse(response);
    return PaginatedResponse.fromJson(
      json['data'] as Map<String, dynamic>,
      (item) => OrderModel.fromJson(item as Map<String, dynamic>),
    );
  }

  // Update order status
  static Future<ApiResponse<OrderModel>> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
    String? trackingNumber,
  }) async {
    final response = await ApiClient.patch(
      '${AppConstants.updateOrderStatusEndpoint}/$orderId',
      token: token,
      body: {
        'status': status,
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => OrderModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // Track order
  static Future<ApiResponse<OrderTracking>> trackOrder({
    required String token,
    required String orderId,
  }) async {
    final response = await ApiClient.get(
      '${AppConstants.orderTrackingEndpoint}/$orderId/tracking',
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => OrderTracking.fromJson(data as Map<String, dynamic>),
    );
  }

  // Get order history
  static Future<PaginatedResponse<OrderModel>> getOrderHistory({
    required String token,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };

    final response = await ApiClient.get(
      AppConstants.orderHistoryEndpoint,
      token: token,
      queryParameters: queryParams,
    );

    final json = ApiClient.handleResponse(response);
    return PaginatedResponse.fromJson(
      json['data'] as Map<String, dynamic>,
      (item) => OrderModel.fromJson(item as Map<String, dynamic>),
    );
  }
}

class CreateOrderRequest {
  final List<OrderItem> items;
  final Map<String, dynamic>? deliveryAddress;
  final DateTime? scheduledDeliveryDate;
  final String? deliveryInstructions;
  final PaymentMethod paymentMethod;
  final String? couponCode;

  CreateOrderRequest({
    required this.items,
    this.deliveryAddress,
    this.scheduledDeliveryDate,
    this.deliveryInstructions,
    required this.paymentMethod,
    this.couponCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
      if (scheduledDeliveryDate != null)
        'scheduledDeliveryDate': scheduledDeliveryDate!.toIso8601String(),
      if (deliveryInstructions != null)
        'deliveryInstructions': deliveryInstructions,
      'paymentMethod': paymentMethod.name,
      if (couponCode != null) 'couponCode': couponCode,
    };
  }
}

class OrderTracking {
  final String orderId;
  final String status;
  final List<TrackingUpdate> updates;
  final DateTime? estimatedDeliveryDate;
  final String? trackingNumber;

  OrderTracking({
    required this.orderId,
    required this.status,
    required this.updates,
    this.estimatedDeliveryDate,
    this.trackingNumber,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? '',
      updates: (json['updates'] as List? ?? [])
          .map((item) => TrackingUpdate.fromJson(item as Map<String, dynamic>))
          .toList(),
      estimatedDeliveryDate: json['estimatedDeliveryDate'] != null
          ? DateTime.parse(json['estimatedDeliveryDate'])
          : null,
      trackingNumber: json['trackingNumber'],
    );
  }
}

class TrackingUpdate {
  final String status;
  final String? message;
  final DateTime timestamp;
  final String? location;

  TrackingUpdate({
    required this.status,
    this.message,
    required this.timestamp,
    this.location,
  });

  factory TrackingUpdate.fromJson(Map<String, dynamic> json) {
    return TrackingUpdate(
      status: json['status'] ?? '',
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
    );
  }
}

