// Products Routes
// These endpoints match: lib/core/api/services/product_api_service.dart

const express = require('express');
const router = express.Router();
const productsController = require('../controllers/products.controller');
const { authenticateToken } = require('../middleware/auth.middleware');

/**
 * GET /v1/products
 * Matches: ProductApiService.getProducts()
 * Query: page, pageSize, category, minPrice, maxPrice, search, inStock, region, latitude, longitude, maxDistance, sortBy, sortOrder
 * Response: { success, data: { data: [...], currentPage, totalPages, ... } }
 */
router.get('/', productsController.getProducts);

/**
 * GET /v1/products/:productId
 * Matches: ProductApiService.getProductById()
 * Response: { success, data: {...product...} }
 */
router.get('/:productId', productsController.getProductById);

/**
 * GET /v1/products/search
 * Matches: ProductApiService.searchProducts()
 * Query: q, page, pageSize, category, minPrice, maxPrice, latitude, longitude, maxDistance
 */
router.get('/search', productsController.searchProducts);

/**
 * GET /v1/products/category/:categoryId
 * Matches: ProductApiService.getProductsByCategory()
 * Query: page, pageSize
 */
router.get('/category/:categoryId', productsController.getProductsByCategory);

/**
 * GET /v1/products/popular
 * Matches: ProductApiService.getPopularProducts()
 * Query: limit
 */
router.get('/popular', productsController.getPopularProducts);

/**
 * GET /v1/products/new
 * Matches: ProductApiService.getNewProducts()
 * Query: limit
 */
router.get('/new', productsController.getNewProducts);

/**
 * GET /v1/products/region
 * Matches: ProductApiService.getRegionSpecificProducts()
 * Query: region, page, pageSize
 */
router.get('/region', productsController.getRegionSpecificProducts);

module.exports = router;

