const express = require('express');
const router = express.Router();
const inventoryController = require('../controllers/inventory.controller');
const { authenticateToken, requireAuth } = require('../middleware/auth.middleware');

// GET /inventory
router.get('/', authenticateToken, requireAuth, inventoryController.getInventory);

// GET /inventory/stats
router.get('/stats', authenticateToken, requireAuth, inventoryController.getInventoryStats);

// POST /inventory/products
router.post('/products', authenticateToken, requireAuth, inventoryController.addProduct);

// PUT /inventory/products/:productId
router.put('/products/:productId', authenticateToken, requireAuth, inventoryController.updateProduct);

// DELETE /inventory/products/:productId
router.delete('/products/:productId', authenticateToken, requireAuth, inventoryController.deleteProduct);

// PATCH /inventory/stock/:productId
router.patch('/stock/:productId', authenticateToken, requireAuth, inventoryController.updateStock);

module.exports = router;
