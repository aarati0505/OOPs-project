const { verifyToken } = require('../services/auth.service');
const User = require('../models/User');
const { errorResponse, createApiError } = require('../utils/response.util');

/**
 * Authentication middleware
 */

/**
 * Verify JWT token from Authorization header
 * @param {object} req - Express request
 * @param {object} res - Express response
 * @param {function} next - Express next middleware
 */
async function authenticateToken(req, res, next) {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      req.user = null;
      return next(); // Allow unauthenticated requests for some endpoints
    }

    const decoded = await verifyToken(token);
    
    // Fetch user from database
    const user = await User.findById(decoded.userId).select('-passwordHash -refreshToken');
    
    if (!user) {
      return res.status(401).json(
        errorResponse(
          [createApiError('auth', 'User not found')],
          'Authentication failed'
        )
      );
    }

    req.user = user;
    req.token = token;
    next();
  } catch (error) {
    return res.status(401).json(
      errorResponse(
        [createApiError('auth', error.message || 'Invalid token')],
        'Authentication failed'
      )
    );
  }
}

/**
 * Require authentication - returns 401 if no token
 * @param {object} req - Express request
 * @param {object} res - Express response
 * @param {function} next - Express next middleware
 */
async function requireAuth(req, res, next) {
  if (!req.user || !req.token) {
    return res.status(401).json(
      errorResponse(
        [createApiError('auth', 'Authentication required')],
        'Authentication required'
      )
    );
  }
  next();
}

module.exports = {
  authenticateToken,
  requireAuth,
};
