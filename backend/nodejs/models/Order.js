// Order Model

const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true,
  },
  productName: {
    type: String,
    required: true,
  },
  productImage: {
    type: String,
  },
  quantity: {
    type: Number,
    required: true,
  },
  unitPrice: {
    type: Number,
    required: true,
  },
  totalPrice: {
    type: Number,
    required: true,
  },
  weight: {
    type: String,
  },
});

const orderSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  userRole: {
    type: String,
    enum: ['customer', 'retailer', 'wholesaler'],
    required: true,
  },
  items: [orderItemSchema],
  totalAmount: {
    type: Number,
    required: true,
  },
  discountAmount: {
    type: Number,
  },
  finalAmount: {
    type: Number,
    required: true,
  },
  deliveryAddress: {
    type: Map,
    of: mongoose.Schema.Types.Mixed,
  },
  scheduledDeliveryDate: {
    type: Date,
  },
  deliveryInstructions: {
    type: String,
  },
  paymentMethod: {
    type: String,
    enum: ['online', 'offline', 'cashOnDelivery'],
    required: true,
  },
  paymentStatus: {
    type: String,
    enum: ['pending', 'completed', 'failed', 'refunded'],
    default: 'pending',
  },
  transactionId: {
    type: String,
  },
  status: {
    type: String,
    enum: ['confirmed', 'processing', 'shipped', 'delivery', 'cancelled'],
    default: 'confirmed',
  },
  retailerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
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
  hasFeedback: {
    type: Boolean,
    default: false,
  },
  rating: {
    type: Number,
    min: 1,
    max: 5,
  },
  feedbackComment: {
    type: String,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
  deliveredAt: {
    type: Date,
  },
});

module.exports = mongoose.model('Order', orderSchema);

