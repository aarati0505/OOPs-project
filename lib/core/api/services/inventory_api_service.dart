import '../../constants/app_constants.dart';
import '../../models/dummy_product_model.dart';
import '../api_client.dart';
import '../models/api_response.dart';

class InventoryApiService {
  // Get retailer/wholesaler inventory
  static Future<PaginatedResponse<ProductModel>> getInventory({
    required String token,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? category,
    bool? inStock,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (category != null) 'category': category,
      if (inStock != null) 'inStock': inStock,
    };

    final response = await ApiClient.get(
      AppConstants.inventoryEndpoint,
      token: token,
      queryParameters: queryParams,
    );

    final json = ApiClient.handleResponse(response);
    return PaginatedResponse.fromJson(
      json['data'] as Map<String, dynamic>,
      (item) => ProductModel.fromJson(item as Map<String, dynamic>),
    );
  }

  // Add product to inventory
  static Future<ApiResponse<ProductModel>> addProduct({
    required String token,
    required ProductModel product,
  }) async {
    final response = await ApiClient.post(
      AppConstants.addProductEndpoint,
      token: token,
      body: product.toJson(),
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => ProductModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // Update product in inventory
  static Future<ApiResponse<ProductModel>> updateProduct({
    required String token,
    required String productId,
    required Map<String, dynamic> updates,
  }) async {
    final response = await ApiClient.put(
      '${AppConstants.updateProductEndpoint}/$productId',
      token: token,
      body: updates,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => ProductModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // Delete product from inventory
  static Future<ApiResponse<void>> deleteProduct({
    required String token,
    required String productId,
  }) async {
    final response = await ApiClient.delete(
      '${AppConstants.deleteProductEndpoint}/$productId',
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(json, null);
  }

  // Update stock quantity
  static Future<ApiResponse<ProductModel>> updateStock({
    required String token,
    required String productId,
    required int quantity,
    required String operation, // 'add', 'subtract', 'set'
  }) async {
    final response = await ApiClient.patch(
      '${AppConstants.updateStockEndpoint}/$productId',
      token: token,
      body: {
        'quantity': quantity,
        'operation': operation,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => ProductModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // Get inventory statistics
  static Future<ApiResponse<Map<String, dynamic>>> getInventoryStats({
    required String token,
  }) async {
    final response = await ApiClient.get(
      '${AppConstants.inventoryEndpoint}/stats',
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => data as Map<String, dynamic>,
    );
  }
}

