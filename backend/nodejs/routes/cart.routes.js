// Cart Routes
// These endpoints match: lib/core/api/services/cart_api_service.dart

const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cart.controller');
const { authenticateToken } = require('../middleware/auth.middleware');

// All routes require authentication
router.use(authenticateToken);

/**
 * GET /v1/cart
 * Matches: CartApiService.getCart()
 */
router.get('/', cartController.getCart);

/**
 * POST /v1/cart/items
 * Matches: CartApiService.addToCart()
 * Request: { productId, quantity }
 */
router.post('/items', cartController.addToCart);

/**
 * PUT /v1/cart/items/:itemId
 * Matches: CartApiService.updateCartItem()
 * Request: { quantity }
 */
router.put('/items/:itemId', cartController.updateCartItem);

/**
 * DELETE /v1/cart/items/:itemId
 * Matches: CartApiService.removeFromCart()
 */
router.delete('/items/:itemId', cartController.removeFromCart);

/**
 * POST /v1/cart/clear
 * Matches: CartApiService.clearCart()
 */
router.post('/clear', cartController.clearCart);

module.exports = router;

