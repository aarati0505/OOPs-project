const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String },
  price: { type: Number, required: true, min: 0 },
  stock: { type: Number, required: true, default: 0, min: 0 },
  categoryId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Category', 
    required: true 
  },
  retailerId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User',
  },
  wholesalerId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User',
  },
  isLocal: { type: Boolean, default: false }, // Local product flag
  region: { type: String }, // Region for filtering
  images: [{ type: String }], // Array of image URLs
  weight: { type: String }, // e.g., "1kg", "500g"
  // Additional fields
  isActive: { type: Boolean, default: true },
  views: { type: Number, default: 0 },
  rating: { type: Number, default: 0 }, // Average rating
  reviewCount: { type: Number, default: 0 },
}, {
  timestamps: true,
});

// Indexes
productSchema.index({ categoryId: 1 });
productSchema.index({ retailerId: 1 });
productSchema.index({ wholesalerId: 1 });
productSchema.index({ region: 1 });
productSchema.index({ isLocal: 1 });
productSchema.index({ name: 'text', description: 'text' }); // Text search
productSchema.index({ price: 1 });
productSchema.index({ isActive: 1 });

// Virtual for inStock
productSchema.virtual('inStock').get(function() {
  return this.stock > 0;
});

// Ensure virtuals are included in JSON
productSchema.set('toJSON', { virtuals: true });

const Product = mongoose.model('Product', productSchema);

module.exports = Product;
