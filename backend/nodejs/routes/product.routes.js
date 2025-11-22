const express = require('express');
const router = express.Router();
const productController = require('../controllers/product.controller');
const { authenticateToken } = require('../middleware/auth.middleware');

// GET /products
router.get('/', authenticateToken, productController.getProducts);

// GET /products/:productId
router.get('/:productId', authenticateToken, productController.getProductById);

// GET /products/search
router.get('/search', authenticateToken, productController.searchProducts);

// GET /products/category/:categoryId
router.get('/category/:categoryId', authenticateToken, productController.getProductsByCategory);

// GET /products/popular
router.get('/popular', authenticateToken, productController.getPopularProducts);

// GET /products/new
router.get('/new', authenticateToken, productController.getNewProducts);

// GET /products/region
router.get('/region', authenticateToken, productController.getRegionSpecificProducts);

// POST /products - Create new product (retailers/wholesalers only)
router.post('/', authenticateToken, productController.createProduct);

// PUT /products/:productId - Update product
router.put('/:productId', authenticateToken, productController.updateProduct);

// DELETE /products/:productId - Delete product
router.delete('/:productId', authenticateToken, productController.deleteProduct);

module.exports = router;

