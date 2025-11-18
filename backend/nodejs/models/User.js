// User Model (MongoDB/Mongoose example)
// Adjust schema based on your database choice (PostgreSQL, MongoDB, etc.)

const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
  },
  phoneNumber: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
  role: {
    type: String,
    enum: ['customer', 'retailer', 'wholesaler'],
    required: true,
    default: 'customer',
  },
  profileImageUrl: {
    type: String,
  },
  location: {
    latitude: Number,
    longitude: Number,
    address: String,
  },
  businessName: {
    type: String, // For retailers and wholesalers
  },
  businessAddress: {
    type: String, // For retailers and wholesalers
  },
  isEmailVerified: {
    type: Boolean,
    default: false,
  },
  isPhoneVerified: {
    type: Boolean,
    default: false,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  lastLoginAt: {
    type: Date,
  },
});

module.exports = mongoose.model('User', userSchema);

