const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { authenticateToken, requireAuth } = require('../middleware/auth.middleware');

// POST /auth/login
router.post('/login', authController.login);

// POST /auth/signup
router.post('/signup', authController.signup);

// POST /auth/request-otp
router.post('/request-otp', authController.requestOtp);

// POST /auth/verify-otp
router.post('/verify-otp', authController.verifyOtp);

// POST /auth/login/google
router.post('/login/google', authController.loginWithGoogle);

// POST /auth/login/facebook
router.post('/login/facebook', authController.loginWithFacebook);

// POST /auth/forgot-password
router.post('/forgot-password', authController.forgotPassword);

// POST /auth/reset-password
router.post('/reset-password', authController.resetPassword);

// POST /auth/logout
router.post('/logout', authenticateToken, requireAuth, authController.logout);

// POST /auth/refresh
router.post('/refresh', authController.refreshToken);

module.exports = router;
