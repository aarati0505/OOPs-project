import '../../constants/app_constants.dart';

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<ApiError>? errors;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.metadata,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: json['errors'] != null
          ? (json['errors'] as List)
              .map((e) => ApiError.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': data,
      if (errors != null) 'errors': errors?.map((e) => e.toJson()).toList(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}

class ApiError {
  final String field;
  final String message;
  final String? code;

  ApiError({
    required this.field,
    required this.message,
    this.code,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'message': message,
      if (code != null) 'code': code,
    };
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List)
          .map((item) => fromJsonT(item))
          .toList(),
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      pageSize: json['pageSize'] ?? AppConstants.defaultPageSize,
      hasNext: json['hasNext'] ?? false,
      hasPrevious: json['hasPrevious'] ?? false,
    );
  }
}

