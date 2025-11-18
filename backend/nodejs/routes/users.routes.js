// User/Profile Routes
// These endpoints match: lib/core/api/services/user_api_service.dart

const express = require('express');
const router = express.Router();
const usersController = require('../controllers/users.controller');
const { authenticateToken } = require('../middleware/auth.middleware');

// All routes require authentication
router.use(authenticateToken);

/**
 * GET /v1/users/profile
 * Matches: UserApiService.getUserProfile()
 */
router.get('/profile', usersController.getProfile);

/**
 * PUT /v1/users/profile
 * Matches: UserApiService.updateProfile()
 */
router.put('/profile', usersController.updateProfile);

/**
 * POST /v1/users/change-password
 * Matches: UserApiService.changePassword()
 * Request: { currentPassword, newPassword }
 */
router.post('/change-password', usersController.changePassword);

/**
 * GET /v1/users/addresses
 * Matches: UserApiService.getUserAddresses()
 */
router.get('/addresses', usersController.getAddresses);

/**
 * POST /v1/users/addresses
 * Matches: UserApiService.addAddress()
 */
router.post('/addresses', usersController.addAddress);

/**
 * PUT /v1/users/addresses/:addressId
 * Matches: UserApiService.updateAddress()
 */
router.put('/addresses/:addressId', usersController.updateAddress);

/**
 * DELETE /v1/users/addresses/:addressId
 * Matches: UserApiService.deleteAddress()
 */
router.delete('/addresses/:addressId', usersController.deleteAddress);

module.exports = router;

