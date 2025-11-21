// API Configuration Constants (matching Dart app_constants.dart)
module.exports = {
  // API Configuration
  apiBaseUrl: process.env.API_BASE_URL || 'http://localhost:3000/v1',
  apiTimeout: parseInt(process.env.API_TIMEOUT) || 30000, // 30 seconds

  // API Endpoints (matching Dart AppConstants)
  endpoints: {
    // Auth Endpoints
    login: '/auth/login',
    signup: '/auth/signup',
    logout: '/auth/logout',
    refreshToken: '/auth/refresh',
    verifyOtp: '/auth/verify-otp',
    forgotPassword: '/auth/forgot-password',
    resetPassword: '/auth/reset-password',

    // User Endpoints
    userProfile: '/users/profile',
    updateProfile: '/users/profile',
    changePassword: '/users/change-password',
    userAddresses: '/users/addresses',
    userAddressDetail: '/users/addresses',

    // Product Endpoints
    products: '/products',
    productDetail: '/products',
    productsByCategory: '/products/category',
    searchProducts: '/products/search',
    popularProducts: '/products/popular',
    newProducts: '/products/new',
    regionSpecificProducts: '/products/region',

    // Inventory Endpoints
    inventory: '/inventory',
    inventoryDetail: '/inventory',
    addProduct: '/inventory/products',
    updateProduct: '/inventory/products',
    deleteProduct: '/inventory/products',
    updateStock: '/inventory/stock',

    // Order Endpoints
    orders: '/orders',
    orderDetail: '/orders',
    createOrder: '/orders',
    updateOrderStatus: '/orders',
    orderHistory: '/orders/history',
    orderTracking: '/orders',

    // Retailer Order Endpoints
    retailerOrders: '/retailers/orders',
    customerOrders: '/retailers/orders/customers',
    wholesalerOrders: '/retailers/orders/wholesalers',

    // Wholesaler Order Endpoints
    wholesalerRetailerOrders: '/wholesalers/orders/retailers',

    // Cart Endpoints
    cart: '/cart',
    addToCart: '/cart/items',
    updateCartItem: '/cart/items',
    removeFromCart: '/cart/items',
    clearCart: '/cart/clear',

    // Location Endpoints
    nearbyShops: '/location/nearby-shops',
    shopLocations: '/location/shops',
    distanceCalculation: '/location/distance',

    // Review Endpoints
    reviews: '/reviews',
    productReviews: '/reviews/products',
    createReview: '/reviews',
    updateReview: '/reviews',

    // Category Endpoints
    categories: '/categories',

    // Notification Endpoints
    notifications: '/notifications',
    markNotificationRead: '/notifications/read',

    // Payment Endpoints
    paymentMethods: '/payment/methods',
    processPayment: '/payment/process',
    paymentHistory: '/payment/history',
  },

  // Pagination
  defaultPageSize: 20,
  maxPageSize: 100,
};

