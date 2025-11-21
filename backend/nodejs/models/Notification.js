const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  type: {
    type: String,
    enum: ['order', 'promotion', 'system', 'review', 'payment'],
    required: true,
  },
  title: { type: String, required: true },
  message: { type: String, required: true },
  data: { type: mongoose.Schema.Types.Mixed }, // Additional data (orderId, etc.)
  isRead: { type: Boolean, default: false },
}, {
  timestamps: true,
});

// Indexes
notificationSchema.index({ userId: 1 });
notificationSchema.index({ userId: 1, isRead: 1 });
notificationSchema.index({ createdAt: -1 });

const Notification = mongoose.model('Notification', notificationSchema);

module.exports = Notification;
