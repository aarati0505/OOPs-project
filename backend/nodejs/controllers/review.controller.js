const Review = require('../models/Review');
const Product = require('../models/Product');
const { successResponse, errorResponse, createApiError } = require('../utils/response.util');
const { parsePagination, calculatePagination } = require('../utils/pagination.util');

/**
 * Review Controller
 * Matching Dart ReviewApiService methods
 */

/**
 * GET /reviews/products/:productId
 * Get product reviews
 * Matching: ReviewApiService.getProductReviews()
 */
exports.getProductReviews = async (req, res) => {
  try {
    const { productId } = req.params;
    const pagination = parsePagination(req.query);
    const { minRating } = req.query;

    const query = { productId };
    if (minRating) {
      query.rating = { $gte: parseInt(minRating) };
    }

    const [reviews, totalItems] = await Promise.all([
      Review.find(query)
        .populate('userId', 'name email')
        .sort({ createdAt: -1 })
        .skip(pagination.skip)
        .limit(pagination.limit)
        .lean(),
      Review.countDocuments(query),
    ]);

    // Format reviews (matching Dart ProductReview structure)
    const reviewsResponse = reviews.map(review => ({
      id: review._id.toString(),
      productId: review.productId.toString(),
      userId: review.userId._id.toString(),
      userName: review.userId.name,
      userImage: null, // TODO: Add user image field
      orderId: review.orderId?.toString() || '',
      rating: review.rating,
      comment: review.comment,
      createdAt: review.createdAt.toISOString(),
      updatedAt: review.updatedAt?.toISOString(),
    }));

    const paginationMeta = calculatePagination(totalItems, pagination.page, pagination.pageSize);

    res.json(successResponse({
      data: reviewsResponse,
      ...paginationMeta,
    }));
  } catch (error) {
    console.error('Get reviews error:', error);
    res.status(500).json(errorResponse(createApiError('review', error.message), 'Failed to get reviews'));
  }
};

/**
 * POST /reviews
 * Create review
 * Matching: ReviewApiService.createReview()
 */
exports.createReview = async (req, res) => {
  try {
    const { productId, orderId, rating, comment } = req.body;

    if (!productId || !rating || !comment) {
      return res.status(400).json(
        errorResponse(
          [createApiError('review', 'Product ID, rating, and comment are required')],
          'Validation error'
        )
      );
    }

    if (rating < 1 || rating > 5) {
      return res.status(400).json(
        errorResponse(
          [createApiError('review', 'Rating must be between 1 and 5')],
          'Validation error'
        )
      );
    }

    // Check if product exists
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json(
        errorResponse(
          [createApiError('review', 'Product not found')],
          'Product not found'
        )
      );
    }

    // Check if user already reviewed this product
    const existingReview = await Review.findOne({
      userId: req.user._id,
      productId: productId,
    });

    if (existingReview) {
      return res.status(409).json(
        errorResponse(
          [createApiError('review', 'You have already reviewed this product')],
          'Review already exists'
        )
      );
    }

    const review = new Review({
      userId: req.user._id,
      productId,
      orderId,
      rating: parseFloat(rating),
      comment,
    });

    await review.save();
    await review.populate('userId', 'name email');

    // Product rating will be updated automatically via post-save hook

    const reviewResponse = {
      id: review._id.toString(),
      productId: review.productId.toString(),
      userId: review.userId._id.toString(),
      userName: review.userId.name,
      userImage: null,
      orderId: review.orderId?.toString() || '',
      rating: review.rating,
      comment: review.comment,
      createdAt: review.createdAt.toISOString(),
    };

    res.json(successResponse(reviewResponse, 'Review created successfully'));
  } catch (error) {
    console.error('Create review error:', error);
    res.status(500).json(errorResponse(createApiError('review', error.message), 'Failed to create review'));
  }
};

/**
 * PUT /reviews/:reviewId
 * Update review
 * Matching: ReviewApiService.updateReview()
 */
exports.updateReview = async (req, res) => {
  try {
    const { reviewId } = req.params;
    const { rating, comment } = req.body;

    const review = await Review.findOne({ _id: reviewId, userId: req.user._id });
    if (!review) {
      return res.status(404).json(
        errorResponse(
          [createApiError('review', 'Review not found')],
          'Review not found'
        )
      );
    }

    if (rating !== undefined) {
      if (rating < 1 || rating > 5) {
        return res.status(400).json(
          errorResponse(
            [createApiError('review', 'Rating must be between 1 and 5')],
            'Validation error'
          )
        );
      }
      review.rating = parseFloat(rating);
    }

    if (comment !== undefined) {
      review.comment = comment;
    }

    await review.save();
    await review.populate('userId', 'name email');

    const reviewResponse = {
      id: review._id.toString(),
      productId: review.productId.toString(),
      userId: review.userId._id.toString(),
      userName: review.userId.name,
      rating: review.rating,
      comment: review.comment,
      updatedAt: review.updatedAt.toISOString(),
    };

    res.json(successResponse(reviewResponse, 'Review updated successfully'));
  } catch (error) {
    console.error('Update review error:', error);
    res.status(500).json(errorResponse(createApiError('review', error.message), 'Failed to update review'));
  }
};

/**
 * DELETE /reviews/:reviewId
 * Delete review
 * Matching: ReviewApiService.deleteReview()
 */
exports.deleteReview = async (req, res) => {
  try {
    const { reviewId } = req.params;

    const review = await Review.findOneAndDelete({ _id: reviewId, userId: req.user._id });
    if (!review) {
      return res.status(404).json(
        errorResponse(
          [createApiError('review', 'Review not found')],
          'Review not found'
        )
      );
    }

    // Product rating will be updated automatically via post-delete hook

    res.json(successResponse(null, 'Review deleted successfully'));
  } catch (error) {
    console.error('Delete review error:', error);
    res.status(500).json(errorResponse(createApiError('review', error.message), 'Failed to delete review'));
  }
};

/**
 * GET /reviews/products/:productId/statistics
 * Get review statistics for a product
 * Matching: ReviewApiService.getReviewStatistics()
 */
exports.getReviewStatistics = async (req, res) => {
  try {
    const { productId } = req.params;

    const mongoose = require('mongoose');
    const stats = await Review.aggregate([
      { $match: { productId: new mongoose.Types.ObjectId(productId) } },
      {
        $group: {
          _id: null,
          averageRating: { $avg: '$rating' },
          totalReviews: { $sum: 1 },
          ratingDistribution: {
            $push: '$rating',
          },
        },
      },
    ]);

    if (stats.length === 0) {
      return res.json(successResponse({
        averageRating: 0,
        totalReviews: 0,
        ratingDistribution: {},
      }));
    }

    // Calculate rating distribution
    const distribution = {};
    for (let i = 1; i <= 5; i++) {
      distribution[i] = stats[0].ratingDistribution.filter(r => Math.round(r) === i).length;
    }

    const statisticsResponse = {
      averageRating: parseFloat(stats[0].averageRating.toFixed(2)),
      totalReviews: stats[0].totalReviews,
      ratingDistribution: distribution,
    };

    res.json(successResponse(statisticsResponse));
  } catch (error) {
    console.error('Get review statistics error:', error);
    res.status(500).json(errorResponse(createApiError('review', error.message), 'Failed to get review statistics'));
  }
};
