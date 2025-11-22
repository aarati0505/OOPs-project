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

    // DEVELOPMENT MODE: Allow user identification by email in custom header
    // This is a temporary workaround until proper JWT token storage is implemented
    if (process.env.NODE_ENV === 'development' && req.headers['x-user-email']) {
      const userEmail = req.headers['x-user-email'];
      console.log(`🔧 DEV MODE: Authenticating user by email: ${userEmail}`);
      
      const user = await User.findOne({ email: userEmail })
        .select('_id name email phone role isEmailVerified isPhoneVerified businessName businessAddress location createdAt lastLoginAt')
        .lean();
      
      if (user) {
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
        console.log(`✅ DEV MODE: User authenticated: ${user.name} (${user.role})`);
        return next();
      } else {
        console.log(`❌ DEV MODE: User not found with email: ${userEmail}`);
        console.log(`💡 Available users: retailer@test.com, wholesaler@test.com`);
        return next(new UnauthorizedError(`User not found with email: ${userEmail}. Please login with a valid account.`));
      }
    }

    // Normal JWT token verification
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
