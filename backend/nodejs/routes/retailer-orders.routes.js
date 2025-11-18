// Retailer Order Routes
// These endpoints match: lib/core/api/services/order_api_service.dart

const express = require('express');
const router = express.Router();
const retailerOrdersController = require('../controllers/retailer-orders.controller');
const { authenticateToken, checkRole } = require('../middleware/auth.middleware');

// All routes require retailer authentication
router.use(authenticateToken);
router.use(checkRole(['retailer']));

/**
 * GET /v1/retailers/orders/customers
 * Matches: OrderApiService.getRetailerCustomerOrders()
 * Query: page, pageSize, status
 */
router.get('/customers', retailerOrdersController.getCustomerOrders);

/**
 * GET /v1/retailers/orders/wholesalers
 * Matches: OrderApiService.getRetailerWholesalerOrders()
 * Query: page, pageSize, status
 */
router.get('/wholesalers', retailerOrdersController.getWholesalerOrders);

module.exports = router;

