const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';
const JWT_REFRESH_EXPIRES_IN = process.env.JWT_REFRESH_EXPIRES_IN || '30d';

/**
 * Authentication Service
 */

/**
 * Hash password
 * @param {string} password - Plain text password
 * @returns {Promise<string>} Hashed password
 */
async function hashPassword(password) {
  const saltRounds = 10;
  return bcrypt.hash(password, saltRounds);
}

/**
 * Compare password with hash
 * @param {string} password - Plain text password
 * @param {string} hash - Hashed password
 * @returns {Promise<boolean>} True if match
 */
async function comparePassword(password, hash) {
  return bcrypt.compare(password, hash);
}

/**
 * Generate JWT access token
 * @param {object} user - User object
 * @returns {string} JWT token
 */
function generateAccessToken(user) {
  const payload = {
    userId: user._id || user.id,
    email: user.email,
    role: user.role,
  };
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN });
}

/**
 * Generate JWT refresh token
 * @param {object} user - User object
 * @returns {string} JWT refresh token
 */
function generateRefreshToken(user) {
  const payload = {
    userId: user._id || user.id,
    type: 'refresh',
  };
  return jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_REFRESH_EXPIRES_IN });
}

/**
 * Verify JWT token
 * @param {string} token - JWT token
 * @returns {Promise<object>} Decoded token payload
 */
async function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    throw new Error('Invalid or expired token');
  }
}

/**
 * Generate numeric OTP code
 * @returns {string}
 */
function generateOtpCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

/**
 * Hash OTP code
 * @param {string} otp
 * @returns {Promise<string>}
 */
async function hashOtpCode(otp) {
  const saltRounds = 10;
  return bcrypt.hash(otp, saltRounds);
}

/**
 * Verify OTP code
 * @param {string} otp
 * @param {string} hash
 * @returns {Promise<boolean>}
 */
async function verifyOtpCode(otp, hash) {
  return bcrypt.compare(otp, hash);
}

module.exports = {
  hashPassword,
  comparePassword,
  generateAccessToken,
  generateRefreshToken,
  verifyToken,
  generateOtpCode,
  hashOtpCode,
  verifyOtpCode,
};
