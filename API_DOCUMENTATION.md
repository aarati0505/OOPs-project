# API Documentation

This document describes all the API endpoints for the multi-role e-commerce platform.

## Base URL
```
https://api.yourdomain.com/v1
```

## Authentication
Most endpoints require authentication via Bearer token:
```
Authorization: Bearer <access_token>
```

---

## Authentication Endpoints

### 1. Login
**POST** `/auth/login`

**Request Body:**
```json
{
  "emailOrPhone": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "user_id",
      "name": "John Doe",
      "email": "user@example.com",
      "phoneNumber": "1234567890",
      "role": "customer",
      "isEmailVerified": true,
      "isPhoneVerified": true,
      "createdAt": "2024-01-01T00:00:00Z"
    },
    "accessToken": "jwt_access_token",
    "refreshToken": "jwt_refresh_token"
  }
}
```

### 2. Sign Up
**POST** `/auth/signup`

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "user@example.com",
  "phoneNumber": "1234567890",
  "password": "password123",
  "role": "customer",
  "businessName": "My Shop" (optional, for retailer/wholesaler),
  "businessAddress": "123 Main St" (optional),
  "location": {
    "latitude": 12.345,
    "longitude": 67.890,
    "address": "Full Address"
  } (optional)
}
```

### 3. Verify OTP
**POST** `/auth/verify-otp`

**Request Body:**
```json
{
  "phoneNumber": "1234567890",
  "otp": "1234"
}
```

### 4. Forgot Password
**POST** `/auth/forgot-password`

**Request Body:**
```json
{
  "emailOrPhone": "user@example.com"
}
```

### 5. Reset Password
**POST** `/auth/reset-password`

**Request Body:**
```json
{
  "token": "reset_token",
  "newPassword": "newpassword123"
}
```

### 6. Logout
**POST** `/auth/logout`

**Headers:** `Authorization: Bearer <token>`

### 7. Refresh Token
**POST** `/auth/refresh`

**Request Body:**
```json
{
  "refreshToken": "refresh_token"
}
```

---

## Product Endpoints

### 1. Get Products
**GET** `/products`

**Query Parameters:**
- `page` (int): Page number (default: 1)
- `pageSize` (int): Items per page (default: 20)
- `category` (string): Filter by category
- `minPrice` (float): Minimum price
- `maxPrice` (float): Maximum price
- `search` (string): Search query
- `inStock` (boolean): Filter by stock availability
- `region` (string): Filter by region
- `latitude` (float): User latitude for distance calculation
- `longitude` (float): User longitude for distance calculation
- `maxDistance` (float): Maximum distance in km
- `sortBy` (string): Sort field (price, name, created)
- `sortOrder` (string): asc or desc

**Response:**
```json
{
  "success": true,
  "data": {
    "data": [...products...],
    "currentPage": 1,
    "totalPages": 10,
    "totalItems": 200,
    "pageSize": 20,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

### 2. Get Product by ID
**GET** `/products/:productId`

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "product_id",
    "name": "Product Name",
    "price": 99.99,
    "stockQuantity": 100,
    "isAvailable": true,
    ...
  }
}
```

### 3. Search Products
**GET** `/products/search?q=query&page=1&pageSize=20`

### 4. Get Products by Category
**GET** `/products/category/:categoryId?page=1&pageSize=20`

### 5. Get Popular Products
**GET** `/products/popular?limit=10`

### 6. Get New Products
**GET** `/products/new?limit=10`

### 7. Get Region-Specific Products
**GET** `/products/region?region=RegionName&page=1&pageSize=20`

---

## Inventory Endpoints (Retailer/Wholesaler)

### 1. Get Inventory
**GET** `/inventory?page=1&pageSize=20&category=Category&inStock=true`

**Headers:** `Authorization: Bearer <token>`

### 2. Add Product
**POST** `/inventory/products`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Product Name",
  "category": "Category",
  "price": 99.99,
  "stockQuantity": 100,
  "weight": "500 gm",
  "description": "Product description",
  "images": ["url1", "url2"],
  ...
}
```

### 3. Update Product
**PUT** `/inventory/products/:productId`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Updated Name",
  "price": 89.99,
  "stockQuantity": 150
}
```

### 4. Delete Product
**DELETE** `/inventory/products/:productId`

**Headers:** `Authorization: Bearer <token>`

### 5. Update Stock
**PATCH** `/inventory/stock/:productId`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "quantity": 50,
  "operation": "add" // "add", "subtract", or "set"
}
```

### 6. Get Inventory Statistics
**GET** `/inventory/stats`

**Headers:** `Authorization: Bearer <token>`

---

## Order Endpoints

### 1. Create Order (Customer)
**POST** `/orders`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "items": [
    {
      "productId": "product_id",
      "productName": "Product Name",
      "quantity": 2,
      "unitPrice": 99.99,
      "totalPrice": 199.98,
      "weight": "500 gm"
    }
  ],
  "deliveryAddress": {
    "street": "123 Main St",
    "city": "City",
    "state": "State",
    "zipCode": "12345",
    "latitude": 12.345,
    "longitude": 67.890
  },
  "scheduledDeliveryDate": "2024-12-25T00:00:00Z" (optional),
  "deliveryInstructions": "Ring the bell" (optional),
  "paymentMethod": "online",
  "couponCode": "SAVE10" (optional)
}
```

### 2. Get Customer Orders
**GET** `/orders?page=1&pageSize=20&status=pending`

**Headers:** `Authorization: Bearer <token>`

### 3. Get Order by ID
**GET** `/orders/:orderId`

**Headers:** `Authorization: Bearer <token>`

### 4. Update Order Status
**PATCH** `/orders/:orderId`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "status": "shipped",
  "trackingNumber": "TRACK123" (optional)
}
```

### 5. Track Order
**GET** `/orders/:orderId/tracking`

**Headers:** `Authorization: Bearer <token>`

### 6. Get Order History
**GET** `/orders/history?page=1&pageSize=20&startDate=2024-01-01&endDate=2024-12-31`

**Headers:** `Authorization: Bearer <token>`

---

## Retailer Order Endpoints

### 1. Get Customer Orders (Retailer)
**GET** `/retailers/orders/customers?page=1&pageSize=20&status=pending`

**Headers:** `Authorization: Bearer <token>`

### 2. Get Wholesaler Orders (Retailer)
**GET** `/retailers/orders/wholesalers?page=1&pageSize=20&status=pending`

**Headers:** `Authorization: Bearer <token>`

---

## Wholesaler Order Endpoints

### 1. Get Retailer Orders (Wholesaler)
**GET** `/wholesalers/orders/retailers?page=1&pageSize=20&status=pending`

**Headers:** `Authorization: Bearer <token>`

---

## Cart Endpoints

### 1. Get Cart
**GET** `/cart`

**Headers:** `Authorization: Bearer <token>`

### 2. Add to Cart
**POST** `/cart/items`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "productId": "product_id",
  "quantity": 2
}
```

### 3. Update Cart Item
**PUT** `/cart/items/:itemId`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "quantity": 3
}
```

### 4. Remove from Cart
**DELETE** `/cart/items/:itemId`

**Headers:** `Authorization: Bearer <token>`

### 5. Clear Cart
**POST** `/cart/clear`

**Headers:** `Authorization: Bearer <token>`

---

## User/Profile Endpoints

### 1. Get User Profile
**GET** `/users/profile`

**Headers:** `Authorization: Bearer <token>`

### 2. Update Profile
**PUT** `/users/profile`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Updated Name",
  "phoneNumber": "9876543210",
  "location": {...}
}
```

### 3. Change Password
**POST** `/users/change-password`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "currentPassword": "oldpassword",
  "newPassword": "newpassword"
}
```

### 4. Get User Addresses
**GET** `/users/addresses`

**Headers:** `Authorization: Bearer <token>`

### 5. Add Address
**POST** `/users/addresses`

**Headers:** `Authorization: Bearer <token>`

### 6. Update Address
**PUT** `/users/addresses/:addressId`

**Headers:** `Authorization: Bearer <token>`

### 7. Delete Address
**DELETE** `/users/addresses/:addressId`

**Headers:** `Authorization: Bearer <token>`

---

## Location Endpoints

### 1. Get Nearby Shops
**GET** `/location/nearby-shops?latitude=12.345&longitude=67.890&maxDistance=10&category=Category`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "shop_id",
      "name": "Shop Name",
      "retailerId": "retailer_id",
      "latitude": 12.345,
      "longitude": 67.890,
      "address": "Shop Address",
      "distanceFromUser": 2.5,
      "phone": "1234567890"
    }
  ]
}
```

### 2. Calculate Distance
**GET** `/location/distance?lat1=12.345&lon1=67.890&lat2=12.346&lon2=67.891`

### 3. Get Shop Locations
**GET** `/location/shops?retailerId=retailer_id` or `?wholesalerId=wholesaler_id`

---

## Review/Feedback Endpoints

### 1. Get Product Reviews
**GET** `/reviews/products/:productId?page=1&pageSize=20&minRating=4`

### 2. Create Review
**POST** `/reviews`

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "productId": "product_id",
  "orderId": "order_id",
  "rating": 5,
  "comment": "Great product!"
}
```

### 3. Update Review
**PUT** `/reviews/:reviewId`

**Headers:** `Authorization: Bearer <token>`

### 4. Delete Review
**DELETE** `/reviews/:reviewId`

**Headers:** `Authorization: Bearer <token>`

### 5. Get Review Statistics
**GET** `/reviews/products/:productId/statistics`

**Response:**
```json
{
  "success": true,
  "data": {
    "averageRating": 4.5,
    "totalReviews": 100,
    "ratingDistribution": {
      "5": 50,
      "4": 30,
      "3": 15,
      "2": 3,
      "1": 2
    }
  }
}
```

---

## Category Endpoints

### 1. Get All Categories
**GET** `/categories`

### 2. Get Category by ID
**GET** `/categories/:categoryId`

---

## Notification Endpoints

### 1. Get Notifications
**GET** `/notifications?page=1&pageSize=20&unreadOnly=true`

**Headers:** `Authorization: Bearer <token>`

### 2. Mark Notification as Read
**POST** `/notifications/read/:notificationId`

**Headers:** `Authorization: Bearer <token>`

### 3. Mark All as Read
**POST** `/notifications/read-all`

**Headers:** `Authorization: Bearer <token>`

### 4. Delete Notification
**DELETE** `/notifications/:notificationId`

**Headers:** `Authorization: Bearer <token>`

---

## Error Responses

All endpoints may return error responses:

```json
{
  "success": false,
  "message": "Error message",
  "errors": [
    {
      "field": "email",
      "message": "Email is required",
      "code": "REQUIRED"
    }
  ]
}
```

**HTTP Status Codes:**
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

---

## Notes

1. All timestamps are in ISO 8601 format (UTC)
2. Pagination is 1-indexed (page 1, 2, 3...)
3. All monetary values are in the base currency unit
4. Distance values are in kilometers
5. Image URLs should be publicly accessible
6. Token expiration time is typically 24 hours (configurable)

