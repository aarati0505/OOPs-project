/**
 * Error handling utilities
 * Custom error classes for consistent error handling
 */

const { errorResponse, createApiError } = require('./response.util');

/**
 * Base API Error class
 */
class ApiError extends Error {
  constructor(message, statusCode = 500, field = 'general') {
    super(message);
    this.name = this.constructor.name;
    this.statusCode = statusCode;
    this.field = field;
    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Validation Error (400)
 */
class ValidationError extends ApiError {
  constructor(message, field = 'validation') {
    super(message, 400, field);
    this.name = 'ValidationError';
  }
}

/**
 * Not Found Error (404)
 */
class NotFoundError extends ApiError {
  constructor(message = 'Resource not found', field = 'resource') {
    super(message, 404, field);
    this.name = 'NotFoundError';
  }
}

/**
 * Unauthorized Error (401)
 */
class UnauthorizedError extends ApiError {
  constructor(message = 'Authentication required', field = 'auth') {
    super(message, 401, field);
    this.name = 'UnauthorizedError';
  }
}

/**
 * Forbidden Error (403)
 */
class ForbiddenError extends ApiError {
  constructor(message = 'Access forbidden', field = 'auth') {
    super(message, 403, field);
    this.name = 'ForbiddenError';
  }
}

/**
 * Conflict Error (409)
 */
class ConflictError extends ApiError {
  constructor(message = 'Resource conflict', field = 'resource') {
    super(message, 409, field);
    this.name = 'ConflictError';
  }
}

/**
 * Handle validation errors
 * @param {Error} error - Validation error
 * @returns {object} Formatted error response
 */
function handleValidationError(error) {
  return errorResponse(
    [createApiError(error.field || 'validation', error.message || 'Validation failed')],
    'Validation error'
  );
}

/**
 * Handle database errors
 * @param {Error} error - Database error
 * @returns {object} Formatted error response
 */
function handleDatabaseError(error) {
  // Don't expose database details in production
  const message = process.env.NODE_ENV === 'production' 
    ? 'Database operation failed' 
    : error.message;
  return errorResponse(
    [createApiError('database', message)],
    'Database error'
  );
}

/**
 * Handle authentication errors
 * @param {string} message - Error message
 * @returns {object} Formatted error response
 */
function handleAuthError(message = 'Authentication failed') {
  return errorResponse(
    [createApiError('auth', message)],
    message
  );
}

module.exports = {
  ApiError,
  ValidationError,
  NotFoundError,
  UnauthorizedError,
  ForbiddenError,
  ConflictError,
  handleValidationError,
  handleDatabaseError,
  handleAuthError,
};

