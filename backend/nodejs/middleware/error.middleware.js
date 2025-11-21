/**
 * Error handling middleware
 */

const { errorResponse, createApiError } = require('../utils/response.util');

/**
 * Global error handler middleware
 * @param {Error} err - Error object
 * @param {object} req - Express request
 * @param {object} res - Express response
 * @param {function} next - Express next middleware
 */
function errorHandler(err, req, res, next) {
  // Don't log sensitive data
  const safeError = {
    name: err.name,
    message: err.message,
    field: err.field || 'general',
    statusCode: err.statusCode || 500,
  };

  // Only log full error in development
  if (process.env.NODE_ENV === 'production') {
    console.error('Error:', safeError);
  } else {
    console.error('Error:', err);
    // In development, log stack trace
    if (err.stack) {
      console.error('Stack:', err.stack);
    }
  }

  // Default error
  let statusCode = err.statusCode || 500;
  let message = 'Internal server error';
  let errors = [
    createApiError(err.field || 'general', err.message || 'An unexpected error occurred'),
  ];

  // Handle specific error types
  if (err.name === 'ValidationError' || err.name === 'CastError') {
    statusCode = 400;
    message = 'Validation error';
    // For Mongoose validation errors, extract field-specific messages
    if (err.errors) {
      errors = Object.values(err.errors).map((error) =>
        createApiError(error.path || 'field', error.message)
      );
    }
  } else if (err.name === 'UnauthorizedError') {
    statusCode = 401;
    message = 'Unauthorized';
  } else if (err.name === 'ForbiddenError') {
    statusCode = 403;
    message = 'Access forbidden';
  } else if (err.name === 'NotFoundError') {
    statusCode = 404;
    message = 'Resource not found';
  } else if (err.name === 'ConflictError') {
    statusCode = 409;
    message = 'Resource conflict';
  } else if (err.name === 'MongoServerError' && err.code === 11000) {
    // Duplicate key error
    statusCode = 409;
    message = 'Resource already exists';
    const field = Object.keys(err.keyPattern || {})[0] || 'field';
    errors = [createApiError(field, `${field} already exists`)];
  } else if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    message = 'Invalid token';
    errors = [createApiError('auth', 'Invalid or expired token')];
  } else if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Token expired';
    errors = [createApiError('auth', 'Token has expired')];
  }

  // Don't expose internal errors in production
  if (statusCode === 500 && process.env.NODE_ENV === 'production') {
    errors = [createApiError('general', 'An internal server error occurred')];
  }

  res.status(statusCode).json(errorResponse(errors, message));
}

/**
 * 404 Not Found handler
 * @param {object} req - Express request
 * @param {object} res - Express response
 */
function notFoundHandler(req, res) {
  res.status(404).json(
    errorResponse(
      [
        {
          field: 'route',
          message: `Route ${req.method} ${req.path} not found`,
        },
      ],
      'Route not found'
    )
  );
}

module.exports = {
  errorHandler,
  notFoundHandler,
};

