import '../../constants/app_constants.dart';
import '../api_client.dart';
import '../models/api_response.dart';

class LocationApiService {
  // Get nearby shops
  static Future<ApiResponse<List<ShopLocation>>> getNearbyShops({
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
          .map((item) => ShopLocation.fromJson(item as Map<String, dynamic>))
          .toList()),
    );
  }

  // Calculate distance between two points
  static Future<ApiResponse<DistanceResult>> calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) async {
    final queryParams = <String, dynamic>{
      'lat1': lat1,
      'lon1': lon1,
      'lat2': lat2,
      'lon2': lon2,
    };

    final response = await ApiClient.get(
      AppConstants.distanceCalculationEndpoint,
      queryParameters: queryParams,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => DistanceResult.fromJson(data as Map<String, dynamic>),
    );
  }

  // Get shop locations by retailer/wholesaler
  static Future<ApiResponse<List<ShopLocation>>> getShopLocations({
    String? retailerId,
    String? wholesalerId,
    String? token,
  }) async {
    final queryParams = <String, dynamic>{};
    if (retailerId != null) queryParams['retailerId'] = retailerId;
    if (wholesalerId != null) queryParams['wholesalerId'] = wholesalerId;

    final response = await ApiClient.get(
      AppConstants.shopLocationsEndpoint,
      token: token,
      queryParameters: queryParams,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => ((data as List)
          .map((item) => ShopLocation.fromJson(item as Map<String, dynamic>))
          .toList()),
    );
  }
}

class ShopLocation {
  final String id;
  final String name;
  final String? retailerId;
  final String? wholesalerId;
  final double latitude;
  final double longitude;
  final String address;
  final double? distanceFromUser; // in km
  final String? phone;
  final String? email;

  ShopLocation({
    required this.id,
    required this.name,
    this.retailerId,
    this.wholesalerId,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.distanceFromUser,
    this.phone,
    this.email,
  });

  factory ShopLocation.fromJson(Map<String, dynamic> json) {
    return ShopLocation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      retailerId: json['retailerId'],
      wholesalerId: json['wholesalerId'],
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      distanceFromUser: json['distanceFromUser']?.toDouble(),
      phone: json['phone'],
      email: json['email'],
    );
  }
}

class DistanceResult {
  final double distance; // in km
  final double duration; // in minutes (if available)

  DistanceResult({
    required this.distance,
    required this.duration,
  });

  factory DistanceResult.fromJson(Map<String, dynamic> json) {
    return DistanceResult(
      distance: (json['distance'] ?? 0).toDouble(),
      duration: (json['duration'] ?? 0).toDouble(),
    );
  }
}

