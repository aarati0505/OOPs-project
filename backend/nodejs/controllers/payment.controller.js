const razorpay = require('../services/razorpay.service');

exports.createOrder = async (req, res) => {
  try {
    // Validate Razorpay credentials
    if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
      return res.status(503).json({
        success: false,
        message: 'Payment service is not configured',
      });
    }

    const { amount } = req.body;  // amount in rupees

    if (!amount) {
      return res.status(400).json({
        success: false,
        message: 'Amount is required',
      });
    }

    if (typeof amount !== 'number' || amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Amount must be a positive number',
      });
    }

    const options = {
      amount: Math.round(amount * 100),  // ₹ → paise (ensure integer)
      currency: 'INR',
      receipt: `receipt_${Date.now()}`,
    };

    const order = await razorpay.orders.create(options);

    return res.status(200).json({
      success: true,
      message: 'Order created successfully',
      data: { order },
    });

  } catch (err) {
    console.error('Razorpay createOrder error:', err);
    return res.status(500).json({
      success: false,
      message: 'Failed to create Razorpay order',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined,
    });
  }
};
