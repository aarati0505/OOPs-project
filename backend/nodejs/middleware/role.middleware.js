/**
 * Role-based access control middleware
 * TODO: Implement role checking logic
 */

/**
 * Require specific role(s)
 * @param {string|Array} allowedRoles - Role(s) allowed to access
 * @returns {function} Express middleware
 */
function requireRole(allowedRoles) {
  return (req, res, next) => {
    // TODO: Implement role checking
    // For now, just pass through
    // In actual implementation, check req.user.role against allowedRoles
    const roles = Array.isArray(allowedRoles) ? allowedRoles : [allowedRoles];

    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required',
        errors: [
          {
            field: 'auth',
            message: 'User not authenticated',
          },
        ],
      });
    }

    // TODO: Check if req.user.role is in roles array
    // For now, allow all
    next();
  };
}

module.exports = {
  requireRole,
};

