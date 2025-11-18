import 'dart:async';
import '../../constants/dummy_data.dart';
import '../../models/dummy_product_model.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../enums/user_role.dart';
import '../../enums/dummy_order_status.dart';
import '../models/api_response.dart';
import 'order_api_service.dart';

/// Mock API Service for testing/development
/// This can be used when backend API is not ready
class MockApiService {
  static const Duration _delay = Duration(milliseconds: 500);

  // Simulate network delay
  static Future<T> _delayResponse<T>(T response) async {
    await Future.delayed(_delay);
    return response;
  }

  // Mock login
  static Future<ApiResponse<LoginResponse>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    // Simulate API call
    await _delayResponse(null);

    // Mock successful login
    final user = UserModel(
      id: 'mock_user_1',
      name: 'Demo User',
      email: emailOrPhone.contains('@') ? emailOrPhone : '$emailOrPhone@demo.com',
      phoneNumber: emailOrPhone.replaceAll(RegExp(r'[^0-9]'), ''),
      role: UserRole.customer,
      isEmailVerified: true,
      isPhoneVerified: true,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    return _delayResponse(ApiResponse<LoginResponse>(
      success: true,
      message: 'Login successful',
      data: LoginResponse(
        user: user,
        accessToken: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      ),
    ));
  }

  // Mock get products
  static Future<PaginatedResponse<ProductModel>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
  }) async {
    await _delayResponse(null);

    var products = List<ProductModel>.from(Dummy.products);

    // Apply filters
    if (category != null) {
      products = products.where((p) => p.category == category).toList();
    }

    if (minPrice != null) {
      products = products.where((p) => p.price >= minPrice).toList();
    }

    if (maxPrice != null) {
      products = products.where((p) => p.price <= maxPrice).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      products = products
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query))
          .toList();
    }

    // Pagination
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    final paginatedProducts = products.length > startIndex
        ? products.sublist(
            startIndex,
            endIndex > products.length ? products.length : endIndex,
          )
        : <ProductModel>[];

    final totalPages = (products.length / pageSize).ceil();

    return _delayResponse(PaginatedResponse<ProductModel>(
      data: paginatedProducts,
      currentPage: page,
      totalPages: totalPages,
      totalItems: products.length,
      pageSize: pageSize,
      hasNext: page < totalPages,
      hasPrevious: page > 1,
    ));
  }

  // Mock get product by ID
  static Future<ApiResponse<ProductModel>> getProductById(String productId) async {
    await _delayResponse(null);

    final product = Dummy.products.firstWhere(
      (p) => p.id == productId,
      orElse: () => Dummy.products.first,
    );

    return _delayResponse(ApiResponse<ProductModel>(
      success: true,
      data: product,
    ));
  }

  // Mock create order
  static Future<ApiResponse<OrderModel>> createOrder({
    required CreateOrderRequest request,
  }) async {
    await _delayResponse(null);

    final order = OrderModel(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'mock_user_1',
      userRole: UserRole.customer,
      items: request.items,
      totalAmount: request.items.fold(0.0, (sum, item) => sum + item.totalPrice),
      finalAmount: request.items.fold(0.0, (sum, item) => sum + item.totalPrice),
      paymentMethod: request.paymentMethod,
      deliveryAddress: request.deliveryAddress,
      scheduledDeliveryDate: request.scheduledDeliveryDate,
      deliveryInstructions: request.deliveryInstructions,
      status: OrderStatus.confirmed,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _delayResponse(ApiResponse<OrderModel>(
      success: true,
      message: 'Order created successfully',
      data: order,
    ));
  }

  // Mock get orders
  static Future<PaginatedResponse<OrderModel>> getOrders({
    int page = 1,
    int pageSize = 20,
    String? status,
  }) async {
    await _delayResponse(null);

    // Return empty list for now (you can add mock orders here)
    return _delayResponse(PaginatedResponse<OrderModel>(
      data: [],
      currentPage: page,
      totalPages: 1,
      totalItems: 0,
      pageSize: pageSize,
      hasNext: false,
      hasPrevious: false,
    ));
  }
}

// Mock response models (matching real API responses)
class LoginResponse {
  final UserModel user;
  final String accessToken;
  final String? refreshToken;

  LoginResponse({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });
}

