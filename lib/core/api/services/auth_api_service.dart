import '../../constants/app_constants.dart';
import '../../enums/user_role.dart';
import '../../models/user_model.dart';
import '../api_client.dart';
import '../models/api_response.dart';

class AuthApiService {
  // Login with email/phone and password
  static Future<ApiResponse<LoginResponse>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await ApiClient.post(
      AppConstants.loginEndpoint,
      body: {
        'emailOrPhone': emailOrPhone,
        'password': password,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  // Sign up
  static Future<ApiResponse<LoginResponse>> signup({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
    required UserRole role,
    String? businessName,
    String? businessAddress,
    Map<String, dynamic>? location,
  }) async {
    final response = await ApiClient.post(
      AppConstants.signupEndpoint,
      body: {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'role': role.name,
        if (businessName != null) 'businessName': businessName,
        if (businessAddress != null) 'businessAddress': businessAddress,
        if (location != null) 'location': location,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  // Verify OTP
  static Future<ApiResponse<LoginResponse>> verifyOtp({
    required String phoneNumber,
    required String otp,
    String? role,
    String? name,
    String? email,
    String? password,
    String? businessName,
    String? businessAddress,
  }) async {
    final response = await ApiClient.post(
      AppConstants.verifyOtpEndpoint,
      body: {
        'phoneNumber': phoneNumber,
        'otp': otp,
        if (role != null) 'role': role,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
        if (businessName != null) 'businessName': businessName,
        if (businessAddress != null) 'businessAddress': businessAddress,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  // Forgot password
  static Future<ApiResponse<void>> forgotPassword({
    required String emailOrPhone,
  }) async {
    final response = await ApiClient.post(
      AppConstants.forgotPasswordEndpoint,
      body: {
        'emailOrPhone': emailOrPhone,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(json, null);
  }

  // Reset password
  static Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await ApiClient.post(
      AppConstants.resetPasswordEndpoint,
      body: {
        'token': token,
        'newPassword': newPassword,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(json, null);
  }

  // Logout
  static Future<ApiResponse<void>> logout(String token) async {
    final response = await ApiClient.post(
      AppConstants.logoutEndpoint,
      token: token,
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(json, null);
  }

  // Refresh token
  static Future<ApiResponse<TokenResponse>> refreshToken(String refreshToken) async {
    final response = await ApiClient.post(
      AppConstants.refreshTokenEndpoint,
      body: {
        'refreshToken': refreshToken,
      },
    );

    final json = ApiClient.handleResponse(response);
    return ApiResponse.fromJson(
      json,
      (data) => TokenResponse.fromJson(data as Map<String, dynamic>),
    );
  }
}

class LoginResponse {
  final UserModel user;
  final String accessToken;
  final String? refreshToken;

  LoginResponse({
    required this.user,
    required this.accessToken,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }
}

class TokenResponse {
  final String accessToken;
  final String? refreshToken;

  TokenResponse({
    required this.accessToken,
    this.refreshToken,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }
}

