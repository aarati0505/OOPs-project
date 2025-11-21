/**
 * Error handling middleware
 */

const { errorResponse } = require('../utils/response.util');

/**
 * Global error handler middleware
 * @param {Error} err - Error object
 * @param {object} req - Express request
 * @param {object} res - Express response
 * @param {function} next - Express next middleware
 */
function errorHandler(err, req, res, next) {
  console.error('Error:', err);

  // Default error
  let statusCode = 500;
  let message = 'Internal server error';
  let errors = [
    {
      field: 'general',
      message: err.message || 'An unexpected error occurred',
    },
  ];

  // Handle specific error types
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation error';
  } else if (err.name === 'UnauthorizedError') {
    statusCode = 401;
    message = 'Unauthorized';
  } else if (err.name === 'NotFoundError') {
    statusCode = 404;
    message = 'Resource not found';
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

