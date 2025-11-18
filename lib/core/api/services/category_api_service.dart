import '../../constants/app_constants.dart';
import '../api_client.dart';
import '../models/api_response.dart';

class CategoryApiService {
  // Get all categories
  static Future<ApiResponse<List<Category>>> getCategories({
    String? token,
  }) async {
    final response = await ApiClient.get(
      AppConstants.categoriesEndpoint,
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => ((data as List)
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList()),
    );
  }

  // Get category by ID
  static Future<ApiResponse<Category>> getCategoryById({
    required String categoryId,
    String? token,
  }) async {
    final response = await ApiClient.get(
      '${AppConstants.categoriesEndpoint}/$categoryId',
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => Category.fromJson(data as Map<String, dynamic>),
    );
  }
}

class Category {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int? productCount;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.productCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      productCount: json['productCount'],
    );
  }
}

