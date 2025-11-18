// Product Model

const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  weight: {
    type: String,
  },
  cover: {
    type: String, // Image URL
  },
  images: [{
    type: String, // Array of image URLs
  }],
  price: {
    type: Number,
    required: true,
  },
  mainPrice: {
    type: Number,
  },
  category: {
    type: String,
    required: true,
  },
  description: {
    type: String,
  },
  stockQuantity: {
    type: Number,
    default: 0,
  },
  isAvailable: {
    type: Boolean,
    default: true,
  },
  availabilityDate: {
    type: Date,
  },
  isRegionSpecific: {
    type: Boolean,
    default: false,
  },
  region: {
    type: String,
  },
  retailerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  retailerName: {
    type: String,
  },
  wholesalerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  wholesalerName: {
    type: String,
  },
  isViaWholesaler: {
    type: Boolean,
    default: false,
  },
  shopLocation: {
    latitude: Number,
    longitude: Number,
    address: String,
  },
  distanceFromUser: {
    type: Number, // Calculated, not stored
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Product', productSchema);

