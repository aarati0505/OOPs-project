// Wholesaler Order Routes
// These endpoints match: lib/core/api/services/order_api_service.dart

const express = require('express');
const router = express.Router();
const wholesalerOrdersController = require('../controllers/wholesaler-orders.controller');
const { authenticateToken, checkRole } = require('../middleware/auth.middleware');

// All routes require wholesaler authentication
router.use(authenticateToken);
router.use(checkRole(['wholesaler']));

/**
 * GET /v1/wholesalers/orders/retailers
 * Matches: OrderApiService.getWholesalerRetailerOrders()
 * Query: page, pageSize, status
 */
router.get('/retailers', wholesalerOrdersController.getRetailerOrders);

module.exports = router;

