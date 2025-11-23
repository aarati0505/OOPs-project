const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  productId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Product', 
    required: true 
  },
  quantity: { type: Number, required: true, min: 1 },
  price: { type: Number, required: true, min: 0 }, // Price at time of order
  productName: { type: String }, // Snapshot of product name
  productImage: { type: String }, // Snapshot of product image
}, { _id: true });

const trackingInfoSchema = new mongoose.Schema({
  status: { type: String, required: true },
  message: { type: String },
  location: { type: String },
  timestamp: { type: Date, default: Date.now },
}, { _id: true });

const statusLogSchema = new mongoose.Schema({
  oldStatus: { type: String },
  newStatus: { type: String, required: true },
  changedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  timestamp: { type: Date, default: Date.now },
  notes: { type: String },
}, { _id: true });

const orderSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
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
  items: [orderItemSchema],
  totalAmount: { type: Number, required: true, min: 0 },
  status: {
    type: String,
    enum: ['confirmed', 'processing', 'shipped', 'delivery', 'cancelled'],
    default: 'confirmed',
  },
  paymentMethod: {
    type: String,
    enum: ['card', 'cash_on_delivery', 'paypal', 'wallet'],
    required: true,
  },
  paymentStatus: {
    type: String,
    enum: ['pending', 'paid', 'failed', 'refunded'],
    default: 'pending',
  },
  deliveryAddressId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Address',
  },
  deliveryAddress: { type: mongoose.Schema.Types.Mixed }, // Snapshot of address
  scheduledDeliveryDate: { type: Date },
  deliveryInstructions: { type: String },
  trackingNumber: { type: String },
  trackingInfo: [trackingInfoSchema],
  statusLogs: [statusLogSchema],
  couponCode: { type: String },
  discount: { type: Number, default: 0 },
  finalAmount: { type: Number, required: true, min: 0 },
  placedAt: { type: Date, default: Date.now },
}, {
  timestamps: true,
});

// Indexes
orderSchema.index({ userId: 1 });
orderSchema.index({ retailerId: 1 });
orderSchema.index({ wholesalerId: 1 });
orderSchema.index({ status: 1 });
orderSchema.index({ placedAt: -1 });
orderSchema.index({ userId: 1, status: 1 });

const Order = mongoose.model('Order', orderSchema);

module.exports = Order;
