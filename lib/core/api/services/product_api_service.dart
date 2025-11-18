import '../../constants/app_constants.dart';
import '../../models/dummy_product_model.dart';
import '../api_client.dart';
import '../models/api_response.dart';

class ProductApiService {
  // Get all products with pagination and filters
  static Future<PaginatedResponse<ProductModel>> getProducts({
    String? token,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
    bool? inStock,
    String? region,
    double? latitude,
    double? longitude,
    double? maxDistance,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (category != null) 'category': category,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (searchQuery != null) 'search': searchQuery,
      if (inStock != null) 'inStock': inStock,
      if (region != null) 'region': region,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (maxDistance != null) 'maxDistance': maxDistance,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };

    final response = await ApiClient.get(
      AppConstants.productsEndpoint,
      token: token,
      queryParameters: queryParams,
    );

    final json = ApiClient.handleResponse(response);
    return PaginatedResponse.fromJson(
      json['data'] as Map<String, dynamic>,
      (item) => ProductModel.fromJson(item as Map<String, dynamic>),
    );
  }

  // Get product by ID
  static Future<ApiResponse<ProductModel>> getProductById(
    String productId, {
    String? token,
  }) async {
    final response = await ApiClient.get(
      '${AppConstants.productDetailEndpoint}/$productId',
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => ProductModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // Search products
  static Future<PaginatedResponse<ProductModel>> searchProducts({
    required String query,
    String? token,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? latitude,
    double? longitude,
    double? maxDistance,
  }) async {
    final queryParams = <String, dynamic>{
      'q': query,
      'page': page,
      'pageSize': pageSize,
      if (category != null) 'category': category,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (maxDistance != null) 'maxDistance': maxDistance,
    };

    final response = await ApiClient.get(
      AppConstants.searchProductsEndpoint,
      token: token,
      queryParameters: queryParams,
    );

    final json = ApiClient.handleResponse(response);
    return PaginatedResponse.fromJson(
      json['data'] as Map<String, dynamic>,
      (item) => ProductModel.fromJson(item as Map<String, dynamic>),
    );
  }

  // Get products by category
  static Future<PaginatedResponse<ProductModel>> getProductsByCategory({
    required String categoryId,
    String? token,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    final response = await ApiClient.get(
      '${AppConstants.productsByCategoryEndpoint}/$categoryId',
      token: token,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
    );

    final json = ApiClient.handleResponse(response);
    return PaginatedResponse.fromJson(
      json['data'] as Map<String, dynamic>,
      (item) => ProductModel.fromJson(item as Map<String, dynamic>),
    );
  }

  // Get popular products
  static Future<ApiResponse<List<ProductModel>>> getPopularProducts({
    String? token,
    int limit = 10,
  }) async {
    final response = await ApiClient.get(
      AppConstants.popularProductsEndpoint,
      token: token,
      queryParameters: {'limit': limit},
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => ((data as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList()),
    );
  }

  // Get new products
  static Future<ApiResponse<List<ProductModel>>> getNewProducts({
    String? token,
    int limit = 10,
  }) async {
    final response = await ApiClient.get(
      AppConstants.newProductsEndpoint,
      token: token,
      queryParameters: {'limit': limit},
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => ((data as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList()),
    );
  }

  // Get region-specific products
  static Future<PaginatedResponse<ProductModel>> getRegionSpecificProducts({
    required String region,
    String? token,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
  }) async {
    final response = await ApiClient.get(
      AppConstants.regionSpecificProductsEndpoint,
      token: token,
      queryParameters: {
        'region': region,
        'page': page,
        'pageSize': pageSize,
      },
    );

    final json = ApiClient.handleResponse(response);
    return PaginatedResponse.fromJson(
      json['data'] as Map<String, dynamic>,
      (item) => ProductModel.fromJson(item as Map<String, dynamic>),
    );
  }

  // Get nearby shops/products
  static Future<ApiResponse<List<ProductModel>>> getNearbyShops({
    required double latitude,
    required double longitude,
    required double maxDistance, // in km
    String? token,
    String? category,
  }) async {
    final queryParams = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'maxDistance': maxDistance,
      if (category != null) 'category': category,
    };

    final response = await ApiClient.get(
      AppConstants.nearbyShopsEndpoint,
      token: token,
      queryParameters: queryParams,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => ((data as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList()),
    );
  }
}

