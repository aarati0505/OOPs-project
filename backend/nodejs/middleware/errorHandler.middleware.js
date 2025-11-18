// Error Handler Middleware
// Ensures all errors return the correct format for Flutter ApiResponse

const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  // Default error
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal server error';
  let errors = null;

  // Validation errors
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation error';
    errors = Object.keys(err.errors).map((key) => ({
      field: key,
      message: err.errors[key].message,
      code: 'VALIDATION_ERROR',
    }));
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
    statusCode = 401;
    message = 'Invalid or expired token';
  }

  // MongoDB duplicate key error
  if (err.code === 11000) {
    statusCode = 400;
    message = 'Duplicate entry';
    const field = Object.keys(err.keyPattern)[0];
    errors = [
      {
        field,
        message: `${field} already exists`,
        code: 'DUPLICATE',
      },
    ];
  }

  // Format response to match Flutter ApiResponse
  const response = {
    success: false,
    message,
  };

  if (errors) {
    response.errors = errors;
  }

  if (process.env.NODE_ENV === 'development') {
    response.stack = err.stack;
  }

  res.status(statusCode).json(response);
};

module.exports = errorHandler;

