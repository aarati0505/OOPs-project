const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/review.controller');
const { authenticateToken, requireAuth } = require('../middleware/auth.middleware');

// POST /reviews
router.post('/', authenticateToken, requireAuth, reviewController.createReview);

// GET /reviews/products/:productId
router.get('/products/:productId', authenticateToken, reviewController.getProductReviews);

// GET /reviews/products/:productId/statistics
router.get('/products/:productId/statistics', authenticateToken, reviewController.getReviewStatistics);

// PUT /reviews/:reviewId
router.put('/:reviewId', authenticateToken, requireAuth, reviewController.updateReview);

// DELETE /reviews/:reviewId
router.delete('/:reviewId', authenticateToken, requireAuth, reviewController.deleteReview);

module.exports = router;

