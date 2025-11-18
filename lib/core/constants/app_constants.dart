class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://api.yourdomain.com/v1'; // Change this to your API URL
  static const String apiTimeout = '30s';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/signup';
  static const String logoutEndpoint = '/auth/logout';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String forgotPasswordEndpoint = '/auth/forgot-password';
  static const String resetPasswordEndpoint = '/auth/reset-password';

  // User Endpoints
  static const String userProfileEndpoint = '/users/profile';
  static const String updateProfileEndpoint = '/users/profile';
  static const String changePasswordEndpoint = '/users/change-password';
  static const String userAddressesEndpoint = '/users/addresses';
  static const String userAddressDetailEndpoint = '/users/addresses';

  // Product Endpoints
  static const String productsEndpoint = '/products';
  static const String productDetailEndpoint = '/products';
  static const String productsByCategoryEndpoint = '/products/category';
  static const String searchProductsEndpoint = '/products/search';
  static const String popularProductsEndpoint = '/products/popular';
  static const String newProductsEndpoint = '/products/new';
  static const String regionSpecificProductsEndpoint = '/products/region';

  // Inventory Endpoints (Retailer/Wholesaler)
  static const String inventoryEndpoint = '/inventory';
  static const String inventoryDetailEndpoint = '/inventory';
  static const String addProductEndpoint = '/inventory/products';
  static const String updateProductEndpoint = '/inventory/products';
  static const String deleteProductEndpoint = '/inventory/products';
  static const String updateStockEndpoint = '/inventory/stock';

  // Order Endpoints
  static const String ordersEndpoint = '/orders';
  static const String orderDetailEndpoint = '/orders';
  static const String createOrderEndpoint = '/orders';
  static const String updateOrderStatusEndpoint = '/orders';
  static const String orderHistoryEndpoint = '/orders/history';
  static const String orderTrackingEndpoint = '/orders';

  // Retailer Order Endpoints
  static const String retailerOrdersEndpoint = '/retailers/orders';
  static const String customerOrdersEndpoint = '/retailers/orders/customers';
  static const String wholesalerOrdersEndpoint = '/retailers/orders/wholesalers';

  // Wholesaler Order Endpoints
  static const String wholesalerRetailerOrdersEndpoint = '/wholesalers/orders/retailers';

  // Cart Endpoints
  static const String cartEndpoint = '/cart';
  static const String addToCartEndpoint = '/cart/items';
  static const String updateCartItemEndpoint = '/cart/items';
  static const String removeFromCartEndpoint = '/cart/items';
  static const String clearCartEndpoint = '/cart/clear';

  // Location Endpoints
  static const String nearbyShopsEndpoint = '/location/nearby-shops';
  static const String shopLocationsEndpoint = '/location/shops';
  static const String distanceCalculationEndpoint = '/location/distance';

  // Feedback/Review Endpoints
  static const String reviewsEndpoint = '/reviews';
  static const String productReviewsEndpoint = '/reviews/products';
  static const String createReviewEndpoint = '/reviews';
  static const String updateReviewEndpoint = '/reviews';

  // Category Endpoints
  static const String categoriesEndpoint = '/categories';

  // Notification Endpoints
  static const String notificationsEndpoint = '/notifications';
  static const String markNotificationReadEndpoint = '/notifications/read';

  // Payment Endpoints
  static const String paymentMethodsEndpoint = '/payment/methods';
  static const String processPaymentEndpoint = '/payment/process';
  static const String paymentHistoryEndpoint = '/payment/history';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

