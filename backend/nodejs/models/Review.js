const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  productId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Product', 
    required: true 
  },
  orderId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Order',
  },
  rating: { 
    type: Number, 
    required: true, 
    min: 1, 
    max: 5 
  },
  comment: { type: String, required: true },
}, {
  timestamps: true,
});

// Indexes
reviewSchema.index({ productId: 1 });
reviewSchema.index({ userId: 1 });
reviewSchema.index({ productId: 1, userId: 1 }, { unique: true }); // One review per user per product

// Update product rating when review is saved/updated
reviewSchema.post('save', async function() {
  await this.constructor.updateProductRating(this.productId);
});

reviewSchema.post('findOneAndDelete', async function(doc) {
  if (doc) {
    await doc.constructor.updateProductRating(doc.productId);
  }
});

// Static method to update product rating
reviewSchema.statics.updateProductRating = async function(productId) {
  const Product = mongoose.model('Product');
  const stats = await this.aggregate([
    { $match: { productId: new mongoose.Types.ObjectId(productId) } },
    {
      $group: {
        _id: null,
        averageRating: { $avg: '$rating' },
        reviewCount: { $sum: 1 },
      },
    },
  ]);

  if (stats.length > 0) {
    await Product.findByIdAndUpdate(productId, {
      rating: stats[0].averageRating,
      reviewCount: stats[0].reviewCount,
    });
  } else {
    await Product.findByIdAndUpdate(productId, {
      rating: 0,
      reviewCount: 0,
    });
  }
};

const Review = mongoose.model('Review', reviewSchema);

module.exports = Review;
