/**
 * Error handling utilities
 */

const { errorResponse, createApiError } = require('./response.util');

/**
 * Handle validation errors
 * @param {Error} error - Validation error
 * @returns {object} Formatted error response
 */
function handleValidationError(error) {
  // TODO: Implement validation error handling
  return errorResponse(
    createApiError('validation', error.message || 'Validation failed'),
    'Validation error'
  );
}

/**
 * Handle database errors
 * @param {Error} error - Database error
 * @returns {object} Formatted error response
 */
function handleDatabaseError(error) {
  // TODO: Implement database error handling
  return errorResponse(
    createApiError('database', 'Database operation failed'),
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
    createApiError('auth', message),
    message
  );
}

module.exports = {
  handleValidationError,
  handleDatabaseError,
  handleAuthError,
};

