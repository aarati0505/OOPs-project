import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/review_model.dart';
import '../../constants/app_constants.dart';
import '../../services/local_auth_service.dart';

class ReviewApiService {
  static const String baseUrl = AppConstants.apiBaseUrl;

  // Get reviews for a product
  static Future<List<ReviewModel>> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl${AppConstants.reviewsEndpoint}/product/$productId?page=$page&limit=$limit',
      );

      print('🔍 Fetching reviews for product: $productId');
      print('🔗 URL: $url');

      final response = await http.get(url);

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final List<dynamic> reviewsJson = jsonData['data'] ?? [];
          final reviews = reviewsJson
              .map((json) => ReviewModel.fromJson(json))
              .toList();

          print('✅ Loaded ${reviews.length} reviews');
          return reviews;
        } else {
          print('⚠️ API returned success: false');
          return [];
        }
      } else {
        print('❌ Failed to load reviews: ${response.statusCode}');
        print('Response: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching reviews: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Get review statistics for a product
  static Future<ReviewStats?> getProductReviewStats(String productId) async {
    try {
      final url = Uri.parse(
        '$baseUrl${AppConstants.reviewsEndpoint}/product/$productId/stats',
      );

      print('📊 Fetching review stats for product: $productId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          return ReviewStats.fromJson(jsonData['data']);
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error fetching review stats: $e');
      return null;
    }
  }

  // Create a review (requires authentication)
  static Future<Map<String, dynamic>> createReview({
    required String productId,
    required int rating,
    required String comment,
    String? orderId,
    String? authToken,
    String? userEmail,
  }) async {
    try {
      final url = Uri.parse('$baseUrl${AppConstants.reviewsEndpoint}');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authToken ?? 'dev-token'}',
        if (userEmail != null) 'x-user-email': userEmail,
      };

      final body = json.encode({
        'productId': productId,
        'rating': rating,
        'comment': comment,
        if (orderId != null) 'orderId': orderId,
      });

      print('📝 Creating review for product: $productId');
      print('👤 User email: $userEmail');

      final response = await http.post(url, headers: headers, body: body);

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      final jsonData = json.decode(response.body);

      if (response.statusCode == 201) {
        print('✅ Review created successfully');
        return {
          'success': true,
          'message': jsonData['message'] ?? 'Review created successfully',
        };
      } else {
        print('❌ Failed to create review: ${response.statusCode}');
        print('Response: ${response.body}');
        return {
          'success': false,
          'message': jsonData['message'] ?? 'Failed to submit review',
        };
      }
    } catch (e) {
      print('❌ Error creating review: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  // Update a review (requires authentication)
  static Future<bool> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
    required String authToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl${AppConstants.reviewsEndpoint}/$reviewId');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      final body = json.encode({
        if (rating != null) 'rating': rating,
        if (comment != null) 'comment': comment,
      });

      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('✅ Review updated successfully');
        return true;
      } else {
        print('❌ Failed to update review: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating review: $e');
      return false;
    }
  }

  // Delete a review (requires authentication)
  static Future<bool> deleteReview({
    required String reviewId,
    required String authToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl${AppConstants.reviewsEndpoint}/$reviewId');

      final headers = {
        'Authorization': 'Bearer $authToken',
      };

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        print('✅ Review deleted successfully');
        return true;
      } else {
        print('❌ Failed to delete review: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting review: $e');
      return false;
    }
  }
}
