const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const addressSchema = new mongoose.Schema({
  label: { type: String, required: true }, // 'home', 'work', 'other'
  line1: { type: String, required: true },
  line2: { type: String },
  city: { type: String, required: true },
  region: { type: String, required: true },
  pincode: { type: String, required: true },
  lat: { type: Number },
  lng: { type: Number },
  isDefault: { type: Boolean, default: false },
}, { _id: true });

const locationSchema = new mongoose.Schema({
  city: { type: String },
  region: { type: String },
  lat: { type: Number },
  lng: { type: Number },
}, { _id: false });

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true, index: true },
  phone: { type: String, required: true, unique: true, index: true },
  passwordHash: { type: String, required: true },
  role: {
    type: String,
    enum: ['customer', 'retailer', 'wholesaler'],
    required: true,
    default: 'customer',
  },
  addresses: [addressSchema],
  location: locationSchema,
  isEmailVerified: { type: Boolean, default: false },
  isPhoneVerified: { type: Boolean, default: false },
  businessName: { type: String }, // For retailer/wholesaler
  businessAddress: { type: String }, // For retailer/wholesaler
  lastLoginAt: { type: Date },
  refreshToken: { type: String }, // For JWT refresh
}, {
  timestamps: true, // Adds createdAt and updatedAt
});

// Indexes (email and phone already indexed via unique: true)
userSchema.index({ role: 1 });
userSchema.index({ 'location.region': 1 });

// Method to compare password
userSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.passwordHash);
};

// Method to get JSON representation (exclude passwordHash)
userSchema.methods.toJSON = function() {
  const userObject = this.toObject();
  delete userObject.passwordHash;
  delete userObject.refreshToken;
  return userObject;
};

const User = mongoose.model('User', userSchema);

module.exports = User;
