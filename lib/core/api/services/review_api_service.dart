import '../../constants/app_constants.dart';
import '../api_client.dart';
import '../models/api_response.dart';

class ReviewApiService {
  // Get product reviews
  static Future<PaginatedResponse<ProductReview>> getProductReviews({
    required String productId,
    String? token,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    int? minRating,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (minRating != null) 'minRating': minRating,
    };

    final response = await ApiClient.get(
      '${AppConstants.productReviewsEndpoint}/$productId',
      token: token,
      queryParameters: queryParams,
    );

    final json = ApiClient.handleResponse(response);
    return PaginatedResponse.fromJson(
      json['data'] as Map<String, dynamic>,
      (item) => ProductReview.fromJson(item as Map<String, dynamic>),
    );
  }

  // Create review
  static Future<ApiResponse<ProductReview>> createReview({
    required String token,
    required String productId,
    required String orderId,
    required double rating,
    required String comment,
  }) async {
    final response = await ApiClient.post(
      AppConstants.createReviewEndpoint,
      token: token,
      body: {
        'productId': productId,
        'orderId': orderId,
        'rating': rating,
        'comment': comment,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => ProductReview.fromJson(data as Map<String, dynamic>),
    );
  }

  // Update review
  static Future<ApiResponse<ProductReview>> updateReview({
    required String token,
    required String reviewId,
    double? rating,
    String? comment,
  }) async {
    final response = await ApiClient.put(
      '${AppConstants.updateReviewEndpoint}/$reviewId',
      token: token,
      body: {
        if (rating != null) 'rating': rating,
        if (comment != null) 'comment': comment,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => ProductReview.fromJson(data as Map<String, dynamic>),
    );
  }

  // Delete review
  static Future<ApiResponse<void>> deleteReview({
    required String token,
    required String reviewId,
  }) async {
    final response = await ApiClient.delete(
      '${AppConstants.reviewsEndpoint}/$reviewId',
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(json, null);
  }

  // Get review statistics for a product
  static Future<ApiResponse<ReviewStatistics>> getReviewStatistics({
    required String productId,
  }) async {
    final response = await ApiClient.get(
      '${AppConstants.productReviewsEndpoint}/$productId/statistics',
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => ReviewStatistics.fromJson(data as Map<String, dynamic>),
    );
  }
}

class ProductReview {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userImage;
  final String orderId;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.orderId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userImage: json['userImage'],
      orderId: json['orderId'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

class ReviewStatistics {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // {5: 10, 4: 5, ...}

  ReviewStatistics({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ReviewStatistics.fromJson(Map<String, dynamic> json) {
    return ReviewStatistics(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      ratingDistribution: Map<int, int>.from(
        json['ratingDistribution'] ?? {},
      ),
    );
  }
}

