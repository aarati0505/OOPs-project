const { verifyToken } = require('../services/auth.service');
const User = require('../models/User');
const { UnauthorizedError } = require('../utils/error.util');

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

    if (!authHeader) {
      req.user = null;
      return next(); // Allow unauthenticated requests for some endpoints
    }

    // Extract token from "Bearer TOKEN" format
    const parts = authHeader.split(' ');
    if (parts.length !== 2 || parts[0] !== 'Bearer') {
      req.user = null;
      return next();
    }

    const token = parts[1];

    if (!token || token.trim().length === 0) {
      req.user = null;
      return next();
    }

    // Verify token
    const decoded = await verifyToken(token);
    
    if (!decoded || !decoded.userId) {
      throw new UnauthorizedError('Invalid token payload');
    }
    
    // Fetch user from database - select only safe fields
    const user = await User.findById(decoded.userId)
      .select('_id name email phone role isEmailVerified isPhoneVerified businessName businessAddress location createdAt lastLoginAt')
      .lean();
    
    if (!user) {
      throw new UnauthorizedError('User not found');
    }

    // Attach minimal, safe user object to request
    req.user = {
      _id: user._id,
      id: user._id.toString(),
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      isEmailVerified: user.isEmailVerified,
      isPhoneVerified: user.isPhoneVerified,
      businessName: user.businessName,
      businessAddress: user.businessAddress,
      location: user.location,
    };
    req.token = token;
    next();
  } catch (error) {
    // If it's already an ApiError, pass it through
    if (error.name === 'UnauthorizedError' || error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      return next(error);
    }
    // Otherwise, wrap in UnauthorizedError
    return next(new UnauthorizedError(error.message || 'Invalid token'));
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
    return next(new UnauthorizedError('Authentication required'));
  }
  next();
}

module.exports = {
  authenticateToken,
  requireAuth,
};
