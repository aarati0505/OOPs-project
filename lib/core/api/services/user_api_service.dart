import '../../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../api_client.dart';
import '../models/api_response.dart';

class UserApiService {
  // Get user profile
  static Future<ApiResponse<UserModel>> getUserProfile({
    required String token,
  }) async {
    final response = await ApiClient.get(
      AppConstants.userProfileEndpoint,
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // Update user profile
  static Future<ApiResponse<UserModel>> updateProfile({
    required String token,
    required Map<String, dynamic> updates,
  }) async {
    final response = await ApiClient.put(
      AppConstants.updateProfileEndpoint,
      token: token,
      body: updates,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  // Change password
  static Future<ApiResponse<void>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await ApiClient.post(
      AppConstants.changePasswordEndpoint,
      token: token,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(json, null);
  }

  // Get user addresses
  static Future<ApiResponse<List<Map<String, dynamic>>>> getUserAddresses({
    required String token,
  }) async {
    final response = await ApiClient.get(
      AppConstants.userAddressesEndpoint,
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => ((data as List)
          .map((item) => item as Map<String, dynamic>)
          .toList()),
    );
  }

  // Add user address
  static Future<ApiResponse<Map<String, dynamic>>> addAddress({
    required String token,
    required Map<String, dynamic> address,
  }) async {
    final response = await ApiClient.post(
      AppConstants.userAddressesEndpoint,
      token: token,
      body: address,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => data as Map<String, dynamic>,
    );
  }

  // Update user address
  static Future<ApiResponse<Map<String, dynamic>>> updateAddress({
    required String token,
    required String addressId,
    required Map<String, dynamic> address,
  }) async {
    final response = await ApiClient.put(
      '${AppConstants.userAddressDetailEndpoint}/$addressId',
      token: token,
      body: address,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => data as Map<String, dynamic>,
    );
  }

  // Delete user address
  static Future<ApiResponse<void>> deleteAddress({
    required String token,
    required String addressId,
  }) async {
    final response = await ApiClient.delete(
      '${AppConstants.userAddressDetailEndpoint}/$addressId',
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(json, null);
  }
}

