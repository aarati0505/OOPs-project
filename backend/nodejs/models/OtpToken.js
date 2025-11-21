const mongoose = require('mongoose');

const otpTokenSchema = new mongoose.Schema({
  phoneNumber: {
    type: String,
    required: true,
    index: true,
  },
  otpHash: {
    type: String,
    required: true,
  },
  purpose: {
    type: String,
    enum: ['login', 'signup', 'reset'],
    default: 'login',
  },
  expiresAt: {
    type: Date,
    required: true,
  },
}, {
  timestamps: true,
});

// TTL index for automatic expiration (removes duplicate index warning)
otpTokenSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

const OtpToken = mongoose.model('OtpToken', otpTokenSchema);

module.exports = OtpToken;

