const razorpay = require('../services/razorpay.service');

exports.createOrder = async (req, res) => {
  try {
    const { amount } = req.body;  // amount in rupees

    if (!amount) {
      return res.status(400).json({
        success: false,
        message: 'Amount is required',
      });
    }

    const options = {
      amount: amount * 100,       // ₹ → paise
      currency: 'INR',
      receipt: `receipt_${Date.now()}`,
    };

    const order = await razorpay.orders.create(options);

    return res.status(200).json({
      success: true,
      data: { order },
    });

  } catch (err) {
    console.error('Razorpay createOrder error:', err);
    res.status(500).json({
      success: false,
      message: 'Failed to create Razorpay order',
    });
  }
};
