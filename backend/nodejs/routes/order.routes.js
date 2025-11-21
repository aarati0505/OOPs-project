const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');
const { authenticateToken, requireAuth } = require('../middleware/auth.middleware');

// POST /orders
router.post('/', authenticateToken, requireAuth, orderController.createOrder);

// GET /orders
router.get('/', authenticateToken, requireAuth, orderController.getCustomerOrders);

// GET /orders/history
router.get('/history', authenticateToken, requireAuth, orderController.getOrderHistory);

// GET /orders/:orderId
router.get('/:orderId', authenticateToken, requireAuth, orderController.getOrderById);

// PATCH /orders/:orderId
router.patch('/:orderId', authenticateToken, requireAuth, orderController.updateOrderStatus);

// GET /orders/:orderId/tracking
router.get('/:orderId/tracking', authenticateToken, requireAuth, orderController.trackOrder);

// POST /orders/wholesale
router.post('/wholesale', authenticateToken, requireAuth, orderController.createWholesaleOrder);

// GET /orders/wholesale/retailer
router.get('/wholesale/retailer', authenticateToken, requireAuth, orderController.getWholesaleOrdersForRetailer);

// GET /orders/wholesale/wholesaler
router.get('/wholesale/wholesaler', authenticateToken, requireAuth, orderController.getWholesaleOrdersForWholesaler);

module.exports = router;

