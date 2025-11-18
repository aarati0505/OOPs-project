import '../../constants/app_constants.dart';
import '../api_client.dart';
import '../models/api_response.dart';

class CartApiService {
  // Get cart
  static Future<ApiResponse<CartResponse>> getCart({
    required String token,
  }) async {
    final response = await ApiClient.get(
      AppConstants.cartEndpoint,
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => CartResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  // Add item to cart
  static Future<ApiResponse<CartResponse>> addToCart({
    required String token,
    required String productId,
    required int quantity,
  }) async {
    final response = await ApiClient.post(
      AppConstants.addToCartEndpoint,
      token: token,
      body: {
        'productId': productId,
        'quantity': quantity,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => CartResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  // Update cart item quantity
  static Future<ApiResponse<CartResponse>> updateCartItem({
    required String token,
    required String itemId,
    required int quantity,
  }) async {
    final response = await ApiClient.put(
      '${AppConstants.updateCartItemEndpoint}/$itemId',
      token: token,
      body: {
        'quantity': quantity,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => CartResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  // Remove item from cart
  static Future<ApiResponse<CartResponse>> removeFromCart({
    required String token,
    required String itemId,
  }) async {
    final response = await ApiClient.delete(
      '${AppConstants.removeFromCartEndpoint}/$itemId',
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => CartResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  // Clear cart
  static Future<ApiResponse<void>> clearCart({
    required String token,
  }) async {
    final response = await ApiClient.post(
      AppConstants.clearCartEndpoint,
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(json, null);
  }
}

class CartResponse {
  final List<CartItem> items;
  final double subtotal;
  final double? discount;
  final double total;
  final int itemCount;

  CartResponse({
    required this.items,
    required this.subtotal,
    this.discount,
    required this.total,
    required this.itemCount,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      items: (json['items'] as List? ?? [])
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discount: json['discount']?.toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      itemCount: json['itemCount'] ?? 0,
    );
  }
}

class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? weight;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.weight,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'],
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      weight: json['weight'],
    );
  }
}

