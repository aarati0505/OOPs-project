const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');
const { authenticateToken, requireAuth } = require('../middleware/auth.middleware');

// GET /retailers/orders/customers
router.get('/orders/customers', authenticateToken, requireAuth, orderController.getRetailerCustomerOrders);

// GET /retailers/orders/wholesalers
router.get('/orders/wholesalers', authenticateToken, requireAuth, orderController.getRetailerWholesalerOrders);

module.exports = router;

