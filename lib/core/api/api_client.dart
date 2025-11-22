import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ApiClient {
  static const String _baseUrl = AppConstants.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 30);

  // Get headers with authentication
  static Future<Map<String, String>> _getHeaders({
    String? token,
    bool includeContentType = true,
    String? userEmail,
  }) async {
    final headers = <String, String>{};

    if (includeContentType) {
      headers['Content-Type'] = 'application/json';
    }

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    // DEVELOPMENT MODE: Add user email header for authentication
    // This is a temporary workaround until proper JWT token storage is implemented
    if (userEmail != null) {
      headers['x-user-email'] = userEmail;
      print('🔧 DEV MODE: Adding user email header: $userEmail');
    }

    return headers;
  }

  // GET request
  static Future<http.Response> get(
    String endpoint, {
    String? token,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      var uri = Uri.parse('$_baseUrl$endpoint');
      
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ));
      }

      final response = await http
          .get(
            uri,
            headers: await _getHeaders(token: token),
          )
          .timeout(_timeout);

      return response;
    } catch (e) {
      throw ApiException('GET request failed: $e');
    }
  }

  // POST request
  static Future<http.Response> post(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
    String? userEmail,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      final response = await http
          .post(
            uri,
            headers: await _getHeaders(token: token, userEmail: userEmail),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return response;
    } catch (e) {
      throw ApiException('POST request failed: $e');
    }
  }

  // PUT request
  static Future<http.Response> put(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      final response = await http
          .put(
            uri,
            headers: await _getHeaders(token: token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return response;
    } catch (e) {
      throw ApiException('PUT request failed: $e');
    }
  }

  // PATCH request
  static Future<http.Response> patch(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      final response = await http
          .patch(
            uri,
            headers: await _getHeaders(token: token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return response;
    } catch (e) {
      throw ApiException('PATCH request failed: $e');
    }
  }

  // DELETE request
  static Future<http.Response> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      
      final response = await http
          .delete(
            uri,
            headers: await _getHeaders(token: token),
          )
          .timeout(_timeout);

      return response;
    } catch (e) {
      throw ApiException('DELETE request failed: $e');
    }
  }

  // Handle response and parse JSON
  static Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ApiException(
        'Request failed with status: ${response.statusCode}\n${response.body}',
      );
    }
  }

  // Handle list response
  static List<dynamic> handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw ApiException(
        'Request failed with status: ${response.statusCode}\n${response.body}',
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => message;
}

