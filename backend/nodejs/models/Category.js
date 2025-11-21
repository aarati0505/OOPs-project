const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true, index: true },
  slug: { type: String, required: true, unique: true, lowercase: true, index: true },
  description: { type: String },
  imageUrl: { type: String },
  productCount: { type: Number, default: 0 }, // Cached count
}, {
  timestamps: true,
});

// Indexes (name and slug already indexed via unique: true)
// Additional indexes can be added here if needed

const Category = mongoose.model('Category', categorySchema);

module.exports = Category;
