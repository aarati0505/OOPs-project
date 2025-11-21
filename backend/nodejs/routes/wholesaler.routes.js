const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');
const { authenticateToken, requireAuth } = require('../middleware/auth.middleware');

// GET /wholesalers/orders/retailers
router.get('/orders/retailers', authenticateToken, requireAuth, orderController.getWholesalerRetailerOrders);

module.exports = router;

