const express = require('express');
const router = express.Router();
const productController = require('../controllers/product.controller');
const { authenticateToken } = require('../middleware/auth.middleware');

// GET /products/search - MUST be before /:productId
router.get('/search', authenticateToken, productController.searchProducts);

// GET /products/popular - MUST be before /:productId
router.get('/popular', authenticateToken, productController.getPopularProducts);

// GET /products/new - MUST be before /:productId
router.get('/new', authenticateToken, productController.getNewProducts);

// GET /products/region - MUST be before /:productId
router.get('/region', authenticateToken, productController.getRegionSpecificProducts);

// GET /products/category/:categoryId - MUST be before /:productId
router.get('/category/:categoryId', authenticateToken, productController.getProductsByCategory);

// GET /products
router.get('/', authenticateToken, productController.getProducts);

// GET /products/:productId - MUST be after specific routes
router.get('/:productId', authenticateToken, productController.getProductById);

// POST /products - Create new product (retailers/wholesalers only)
router.post('/', authenticateToken, productController.createProduct);

// PUT /products/:productId - Update product
router.put('/:productId', authenticateToken, productController.updateProduct);

// DELETE /products/:productId - Delete product
router.delete('/:productId', authenticateToken, productController.deleteProduct);

module.exports = router;

