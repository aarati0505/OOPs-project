const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Review = require('../models/Review');
const Product = require('../models/Product');
const { authenticateToken } = require('../middleware/auth.middleware');

// Get reviews for a product
router.get('/product/:productId', async (req, res) => {
  try {
    const { productId } = req.params;
    const { page = 1, limit = 10 } = req.query;
    
    const reviews = await Review.find({ productId })
      .populate('userId', 'name email')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await Review.countDocuments({ productId });
    
    // Get product rating stats
    const product = await Product.findById(productId);
    
    res.json({
      success: true,
      data: reviews,
      pagination: {
        total,
        page: parseInt(page),
        pages: Math.ceil(total / limit),
      },
      stats: {
        averageRating: product?.rating || 0,
        totalReviews: product?.reviewCount || 0,
      }
    });
  } catch (error) {
    console.error('Error fetching reviews:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Error fetching reviews',
      error: error.message 
    });
  }
});

// Get review statistics for a product
router.get('/product/:productId/stats', async (req, res) => {
  try {
    const { productId } = req.params;
    
    const stats = await Review.aggregate([
      { $match: { productId: new mongoose.Types.ObjectId(productId) } },
      {
        $group: {
          _id: '$rating',
          count: { $sum: 1 }
        }
      },
      { $sort: { _id: -1 } }
    ]);
    
    const product = await Product.findById(productId);
    
    res.json({
      success: true,
      data: {
        averageRating: product?.rating || 0,
        totalReviews: product?.reviewCount || 0,
        distribution: stats.reduce((acc, stat) => {
          acc[stat._id] = stat.count;
          return acc;
        }, {})
      }
    });
  } catch (error) {
    console.error('Error fetching review stats:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Error fetching review stats',
      error: error.message 
    });
  }
});

// Create a review (requires authentication)
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { productId, rating, comment, orderId } = req.body;
    const userId = req.user.userId;
    
    // Validate input
    if (!productId || !rating || !comment) {
      return res.status(400).json({
        success: false,
        message: 'Product ID, rating, and comment are required'
      });
    }
    
    if (rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: 'Rating must be between 1 and 5'
      });
    }
    
    // Check if product exists
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }
    
    // Check if user already reviewed this product
    const existingReview = await Review.findOne({ userId, productId });
    if (existingReview) {
      return res.status(400).json({
        success: false,
        message: 'You have already reviewed this product'
      });
    }
    
    // Create review
    const review = await Review.create({
      userId,
      productId,
      rating,
      comment,
      orderId: orderId || null,
    });
    
    // Populate user data
    await review.populate('userId', 'name email');
    
    res.status(201).json({
      success: true,
      message: 'Review created successfully',
      data: review
    });
  } catch (error) {
    console.error('Error creating review:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Error creating review',
      error: error.message 
    });
  }
});

// Update a review (requires authentication)
router.put('/:reviewId', authenticateToken, async (req, res) => {
  try {
    const { reviewId } = req.params;
    const { rating, comment } = req.body;
    const userId = req.user.userId;
    
    const review = await Review.findById(reviewId);
    
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }
    
    // Check if user owns this review
    if (review.userId.toString() !== userId) {
      return res.status(403).json({
        success: false,
        message: 'You can only update your own reviews'
      });
    }
    
    // Update review
    if (rating) review.rating = rating;
    if (comment) review.comment = comment;
    
    await review.save();
    await review.populate('userId', 'name email');
    
    res.json({
      success: true,
      message: 'Review updated successfully',
      data: review
    });
  } catch (error) {
    console.error('Error updating review:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Error updating review',
      error: error.message 
    });
  }
});

// Delete a review (requires authentication)
router.delete('/:reviewId', authenticateToken, async (req, res) => {
  try {
    const { reviewId } = req.params;
    const userId = req.user.userId;
    
    const review = await Review.findById(reviewId);
    
    if (!review) {
      return res.status(404).json({
        success: false,
        message: 'Review not found'
      });
    }
    
    // Check if user owns this review
    if (review.userId.toString() !== userId) {
      return res.status(403).json({
        success: false,
        message: 'You can only delete your own reviews'
      });
    }
    
    await Review.findByIdAndDelete(reviewId);
    
    res.json({
      success: true,
      message: 'Review deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting review:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Error deleting review',
      error: error.message 
    });
  }
});

module.exports = router;
