// Orders Routes
// These endpoints match: lib/core/api/services/order_api_service.dart

const express = require('express');
const router = express.Router();
const ordersController = require('../controllers/orders.controller');
const { authenticateToken } = require('../middleware/auth.middleware');

/**
 * POST /v1/orders
 * Matches: OrderApiService.createOrder()
 * Headers: Authorization: Bearer <token>
 * Request: { items, deliveryAddress, scheduledDeliveryDate?, paymentMethod, couponCode? }
 * Response: { success, message, data: {...order...} }
 */
router.post('/', authenticateToken, ordersController.createOrder);

/**
 * GET /v1/orders/history - MUST be before /:orderId
 * Matches: OrderApiService.getOrderHistory()
 * Headers: Authorization: Bearer <token>
 * Query: page, pageSize, startDate, endDate
 */
router.get('/history', authenticateToken, ordersController.getOrderHistory);

/**
 * GET /v1/orders/user/:userId - MUST be before /:orderId
 * Get all orders for a specific user
 * Headers: Authorization: Bearer <token>
 * Query: page, pageSize, status
 */
router.get('/user/:userId', authenticateToken, ordersController.getUserOrders);

/**
 * GET /v1/orders
 * Matches: OrderApiService.getCustomerOrders()
 * Headers: Authorization: Bearer <token>
 * Query: page, pageSize, status
 */
router.get('/', authenticateToken, ordersController.getCustomerOrders);

/**
 * GET /v1/orders/:orderId/tracking
 * Matches: OrderApiService.trackOrder()
 * Headers: Authorization: Bearer <token>
 */
router.get('/:orderId/tracking', authenticateToken, ordersController.trackOrder);

/**
 * GET /v1/orders/:orderId - MUST be after specific routes
 * Matches: OrderApiService.getOrderById()
 * Headers: Authorization: Bearer <token>
 */
router.get('/:orderId', authenticateToken, ordersController.getOrderById);

/**
 * PATCH /v1/orders/:orderId/status
 * Update order status (alternative endpoint)
 * Headers: Authorization: Bearer <token>
 * Request: { status, trackingNumber?, notes? }
 */
router.patch('/:orderId/status', authenticateToken, ordersController.updateOrderStatus);

/**
 * PATCH /v1/orders/:orderId
 * Matches: OrderApiService.updateOrderStatus()
 * Headers: Authorization: Bearer <token>
 * Request: { status, trackingNumber?, notes? }
 */
router.patch('/:orderId', authenticateToken, ordersController.updateOrderStatus);

module.exports = router;

