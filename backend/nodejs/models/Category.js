const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  slug: { type: String, required: true, unique: true, lowercase: true },
  description: { type: String },
  imageUrl: { type: String },
  productCount: { type: Number, default: 0 }, // Cached count
}, {
  timestamps: true,
});

// Indexes
categorySchema.index({ slug: 1 });
categorySchema.index({ name: 1 });

const Category = mongoose.model('Category', categorySchema);

module.exports = Category;
