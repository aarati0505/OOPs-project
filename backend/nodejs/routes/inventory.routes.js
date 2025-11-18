// Inventory Routes (Retailer/Wholesaler)
// These endpoints match: lib/core/api/services/inventory_api_service.dart

const express = require('express');
const router = express.Router();
const inventoryController = require('../controllers/inventory.controller');
const { authenticateToken, checkRole } = require('../middleware/auth.middleware');

// All routes require authentication and retailer/wholesaler role
router.use(authenticateToken);
router.use(checkRole(['retailer', 'wholesaler']));

/**
 * GET /v1/inventory
 * Matches: InventoryApiService.getInventory()
 * Query: page, pageSize, category, inStock
 */
router.get('/', inventoryController.getInventory);

/**
 * GET /v1/inventory/stats
 * Matches: InventoryApiService.getInventoryStats()
 */
router.get('/stats', inventoryController.getInventoryStats);

/**
 * POST /v1/inventory/products
 * Matches: InventoryApiService.addProduct()
 * Request: ProductModel JSON
 */
router.post('/products', inventoryController.addProduct);

/**
 * PUT /v1/inventory/products/:productId
 * Matches: InventoryApiService.updateProduct()
 */
router.put('/products/:productId', inventoryController.updateProduct);

/**
 * DELETE /v1/inventory/products/:productId
 * Matches: InventoryApiService.deleteProduct()
 */
router.delete('/products/:productId', inventoryController.deleteProduct);

/**
 * PATCH /v1/inventory/stock/:productId
 * Matches: InventoryApiService.updateStock()
 * Request: { quantity, operation: "add"|"subtract"|"set" }
 */
router.patch('/stock/:productId', inventoryController.updateStock);

module.exports = router;

