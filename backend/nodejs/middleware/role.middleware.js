/**
 * Role-based access control middleware
 */

const { ForbiddenError, UnauthorizedError } = require('../utils/error.util');

/**
 * Require specific role(s)
 * @param {string|Array} allowedRoles - Role(s) allowed to access
 * @returns {function} Express middleware
 */
function requireRole(allowedRoles) {
  return (req, res, next) => {
    // Check if user is authenticated
    if (!req.user) {
      return next(new UnauthorizedError('Authentication required'));
    }

    // Normalize allowedRoles to array
    const roles = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];

    // Strict role check
    if (!req.user.role || !roles.includes(req.user.role)) {
      return next(new ForbiddenError(`Access denied. Required role(s): ${roles.join(', ')}`));
    }

    next();
  };
}

/**
 * Require retailer role
 */
function requireRetailer(req, res, next) {
  return requireRole('retailer')(req, res, next);
}

/**
 * Require wholesaler role
 */
function requireWholesaler(req, res, next) {
  return requireRole('wholesaler')(req, res, next);
}

/**
 * Require retailer or wholesaler role
 */
function requireRetailerOrWholesaler(req, res, next) {
  return requireRole(['retailer', 'wholesaler'])(req, res, next);
}

/**
 * Require customer role
 */
function requireCustomer(req, res, next) {
  return requireRole('customer')(req, res, next);
}

module.exports = {
  requireRole,
  requireRetailer,
  requireWholesaler,
  requireRetailerOrWholesaler,
  requireCustomer,
};

