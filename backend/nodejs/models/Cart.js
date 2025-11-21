const mongoose = require('mongoose');

const cartItemSchema = new mongoose.Schema({
  productId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Product', 
    required: true 
  },
  quantity: { type: Number, required: true, min: 1 },
}, { _id: true });

const cartSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true,
    unique: true,
    index: true,
  },
  items: [cartItemSchema],
}, {
  timestamps: true,
});

// Indexes (userId already indexed via unique: true)

const Cart = mongoose.model('Cart', cartSchema);

module.exports = Cart;
