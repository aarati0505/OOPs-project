const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cart.controller');
const { authenticateToken, requireAuth } = require('../middleware/auth.middleware');

// GET /cart
router.get('/', authenticateToken, requireAuth, cartController.getCart);

// POST /cart/items
router.post('/items', authenticateToken, requireAuth, cartController.addToCart);

// PUT /cart/items/:itemId
router.put('/items/:itemId', authenticateToken, requireAuth, cartController.updateCartItem);

// DELETE /cart/items/:itemId
router.delete('/items/:itemId', authenticateToken, requireAuth, cartController.removeFromCart);

// POST /cart/clear
router.post('/clear', authenticateToken, requireAuth, cartController.clearCart);

module.exports = router;
