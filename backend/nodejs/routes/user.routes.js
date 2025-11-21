const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { authenticateToken, requireAuth } = require('../middleware/auth.middleware');

// GET /users/dashboard
router.get('/dashboard', authenticateToken, requireAuth, userController.getDashboard);

// GET /users/profile
router.get('/profile', authenticateToken, requireAuth, userController.getUserProfile);

// PUT /users/profile
router.put('/profile', authenticateToken, requireAuth, userController.updateProfile);

// POST /users/change-password
router.post('/change-password', authenticateToken, requireAuth, userController.changePassword);

// GET /users/addresses
router.get('/addresses', authenticateToken, requireAuth, userController.getUserAddresses);

// POST /users/addresses
router.post('/addresses', authenticateToken, requireAuth, userController.addAddress);

// PUT /users/addresses/:addressId
router.put('/addresses/:addressId', authenticateToken, requireAuth, userController.updateAddress);

// DELETE /users/addresses/:addressId
router.delete('/addresses/:addressId', authenticateToken, requireAuth, userController.deleteAddress);

module.exports = router;

