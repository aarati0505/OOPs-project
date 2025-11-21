/**
 * Response utility functions matching Dart ApiResponse structure
 * Based on lib/core/api/models/api_response.dart
 */

/**
 * Create a success ApiResponse matching Dart structure
 * @param {any} data - Response data
 * @param {string} message - Optional success message
 * @param {object} metadata - Optional metadata
 * @returns {object} ApiResponse object
 */
function successResponse(data, message = null, metadata = null) {
  const response = {
    success: true,
  };

  if (message) {
    response.message = message;
  }

  if (data !== null && data !== undefined) {
    response.data = data;
  }

  if (metadata) {
    response.metadata = metadata;
  }

  return response;
}

/**
 * Create an error ApiResponse matching Dart structure
 * @param {string|Array} errors - Error message(s) or array of ApiError objects
 * @param {string} message - Optional error message
 * @returns {object} ApiResponse object with errors
 */
function errorResponse(errors, message = null) {
  const response = {
    success: false,
  };

  if (message) {
    response.message = message;
  }

  // Handle different error formats
  if (Array.isArray(errors)) {
    response.errors = errors;
  } else if (typeof errors === 'string') {
    response.errors = [
      {
        field: 'general',
        message: errors,
      },
    ];
  } else {
    response.errors = [errors];
  }

  return response;
}

/**
 * Create a paginated response matching Dart PaginatedResponse structure
 * @param {Array} data - Array of items
 * @param {number} currentPage - Current page number
 * @param {number} totalPages - Total number of pages
 * @param {number} totalItems - Total number of items
 * @param {number} pageSize - Items per page
 * @returns {object} Paginated response wrapped in ApiResponse
 */
function paginatedResponse(data, currentPage, totalPages, totalItems, pageSize) {
  return successResponse({
    data: data,
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
    pageSize: pageSize,
    hasNext: currentPage < totalPages,
    hasPrevious: currentPage > 1,
  });
}

/**
 * Create an ApiError object matching Dart structure
 * @param {string} field - Field name
 * @param {string} message - Error message
 * @param {string} code - Optional error code
 * @returns {object} ApiError object
 */
function createApiError(field, message, code = null) {
  const error = {
    field: field,
    message: message,
  };

  if (code) {
    error.code = code;
  }

  return error;
}

module.exports = {
  successResponse,
  errorResponse,
  paginatedResponse,
  createApiError,
};

