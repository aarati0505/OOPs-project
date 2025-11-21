const mongoose = require('mongoose');

const addressSchema = new mongoose.Schema({
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  label: { type: String, required: true }, // 'home', 'work', 'other'
  line1: { type: String, required: true },
  line2: { type: String },
  city: { type: String, required: true },
  region: { type: String, required: true },
  pincode: { type: String, required: true },
  lat: { type: Number },
  lng: { type: Number },
  isDefault: { type: Boolean, default: false },
}, {
  timestamps: true,
});

// Indexes
addressSchema.index({ userId: 1 });
addressSchema.index({ userId: 1, isDefault: 1 });

// Ensure only one default address per user
addressSchema.pre('save', async function(next) {
  if (this.isDefault && this.isModified('isDefault')) {
    await mongoose.model('Address').updateMany(
      { userId: this.userId, _id: { $ne: this._id } },
      { $set: { isDefault: false } }
    );
  }
  next();
});

const Address = mongoose.model('Address', addressSchema);

module.exports = Address;
