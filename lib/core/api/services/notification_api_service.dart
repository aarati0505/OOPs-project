import '../../constants/app_constants.dart';
import '../api_client.dart';
import '../models/api_response.dart';

class NotificationApiService {
  // Get notifications
  static Future<PaginatedResponse<Notification>> getNotifications({
    required String token,
    int page = 1,
    int pageSize = AppConstants.defaultPageSize,
    bool? unreadOnly,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (unreadOnly != null) 'unreadOnly': unreadOnly,
    };

    final response = await ApiClient.get(
      AppConstants.notificationsEndpoint,
      token: token,
      queryParameters: queryParams,
    );

    final json = ApiClient.handleResponse(response);
    return PaginatedResponse.fromJson(
      json['data'] as Map<String, dynamic>,
      (item) => Notification.fromJson(item as Map<String, dynamic>),
    );
  }

  // Mark notification as read
  static Future<ApiResponse<void>> markNotificationRead({
    required String token,
    required String notificationId,
  }) async {
    final response = await ApiClient.post(
      '${AppConstants.markNotificationReadEndpoint}/$notificationId',
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(json, null);
  }

  // Mark all notifications as read
  static Future<ApiResponse<void>> markAllNotificationsRead({
    required String token,
  }) async {
    final response = await ApiClient.post(
      '${AppConstants.notificationsEndpoint}/read-all',
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(json, null);
  }

  // Delete notification
  static Future<ApiResponse<void>> deleteNotification({
    required String token,
    required String notificationId,
  }) async {
    final response = await ApiClient.delete(
      '${AppConstants.notificationsEndpoint}/$notificationId',
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(json, null);
  }
}

class Notification {
  final String id;
  final String title;
  final String message;
  final String type; // 'order', 'promotion', 'system', etc.
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data; // Additional data (orderId, etc.)

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

