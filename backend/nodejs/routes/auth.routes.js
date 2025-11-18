// Authentication Routes
// These endpoints match: lib/core/constants/app_constants.dart -> AppConstants.loginEndpoint, etc.

const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { authenticateToken } = require('../middleware/auth.middleware');

/**
 * POST /v1/auth/login
 * Matches: AuthApiService.login()
 * Request: { emailOrPhone, password }
 * Response: { success, message, data: { user, accessToken, refreshToken } }
 */
router.post('/login', authController.login);

/**
 * POST /v1/auth/signup
 * Matches: AuthApiService.signup()
 * Request: { name, email, phoneNumber, password, role, businessName?, businessAddress? }
 * Response: { success, message, data: { user, accessToken, refreshToken } }
 */
router.post('/signup', authController.signup);

/**
 * POST /v1/auth/verify-otp
 * Matches: AuthApiService.verifyOtp()
 * Request: { phoneNumber, otp }
 * Response: { success, message, data: { user, accessToken } }
 */
router.post('/verify-otp', authController.verifyOtp);

/**
 * POST /v1/auth/forgot-password
 * Matches: AuthApiService.forgotPassword()
 * Request: { emailOrPhone }
 * Response: { success, message }
 */
router.post('/forgot-password', authController.forgotPassword);

/**
 * POST /v1/auth/reset-password
 * Matches: AuthApiService.resetPassword()
 * Request: { token, newPassword }
 * Response: { success, message }
 */
router.post('/reset-password', authController.resetPassword);

/**
 * POST /v1/auth/logout
 * Matches: AuthApiService.logout()
 * Headers: Authorization: Bearer <token>
 * Response: { success, message }
 */
router.post('/logout', authenticateToken, authController.logout);

/**
 * POST /v1/auth/refresh
 * Matches: AuthApiService.refreshToken()
 * Request: { refreshToken }
 * Response: { success, data: { accessToken, refreshToken } }
 */
router.post('/refresh', authController.refreshToken);

module.exports = router;

