const Razorpay = require('razorpay');

// Razorpay instance initialization
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

// Validate Razorpay credentials on initialization
if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
  console.warn('⚠️  Razorpay credentials not found in .env');
  console.warn('   Payment features will be disabled');
}

module.exports = razorpay;
