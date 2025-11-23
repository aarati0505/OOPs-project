class PaymentConstants {
  // Razorpay API Keys
  // TODO: Replace with your actual Razorpay keys from .env or secure storage
  static const String razorpayKeyId = 'rzp_test_RiykKYRYFMVqNR';
  static const String razorpayKeySecret = '5Ye6tHxsESfPbxrhkqS8kqcq'; // Never expose in production!

  // Company/Business Details
  static const String companyName = 'Your Company Name';
  static const String companyLogo = 'https://your-logo-url.com/logo.png';
  static const String currency = 'INR';

  // Check if Razorpay is configured
  static bool get isConfigured => razorpayKeyId.isNotEmpty;

  // Get payment options for Razorpay checkout
  static Map<String, dynamic> getPaymentOptions({
    required double amount,
    required String orderId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) {
    return {
      'key': razorpayKeyId,
      'amount': (amount * 100).toInt(), // Convert to paise
      'currency': currency,
      'name': companyName,
      'description': 'Order Payment',
      'order_id': orderId, // Razorpay order ID from backend
      'prefill': {
        'name': customerName,
        'email': customerEmail,
        'contact': customerPhone,
      },
      'theme': {
        'color': '#2E7D32', // Your brand color
      },
      'modal': {
        'ondismiss': () {
          print('Payment dismissed by user');
        }
      },
      'retry': {
        'enabled': true,
        'max_count': 3,
      },
      'timeout': 300, // 5 minutes
      'readonly': {
        'email': false,
        'contact': false,
      },
    };
  }
}
