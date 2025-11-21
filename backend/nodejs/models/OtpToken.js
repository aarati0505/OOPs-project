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
    index: true,
  },
}, {
  timestamps: true,
});

otpTokenSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

const OtpToken = mongoose.model('OtpToken', otpTokenSchema);

module.exports = OtpToken;

