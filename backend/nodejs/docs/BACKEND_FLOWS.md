# Backend API Flows Documentation

This document provides step-by-step guides for testing the main user flows in the e-commerce backend API.

**Base URL:** `http://localhost:3000/v1`

**Authentication:** Most endpoints require a JWT token in the `Authorization` header:
```
Authorization: Bearer <access_token>
```

---

## 1. Customer Flow

### 1.1 Signup

**Endpoint:** `POST /auth/signup`

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+1234567890",
  "password": "password123",
  "role": "customer"
}
```

**Response:** Returns `ApiResponse` with user object and tokens:
```json
{
  "success": true,
  "message": "Signup successful",
  "data": {
    "user": {
      "id": "...",
      "name": "John Doe",
      "email": "john.doe@example.com",
      "role": "customer"
    },
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc..."
  }
}
```

**Save the `accessToken` for subsequent requests.**

---

### 1.2 Login

**Endpoint:** `POST /auth/login`

**Request Body:**
```json
{
  "emailOrPhone": "john.doe@example.com",
  "password": "password123"
}
```

**Response:** Returns `ApiResponse` with tokens (same format as signup).

---

### 1.3 Get Profile

**Endpoint:** `GET /users/profile`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:** Returns user profile information.

---

### 1.4 Browse Products with Filters

**Endpoint:** `GET /products`

**Query Parameters:**
- `region` - Filter by region (e.g., "HYD", "BLR")
- `minPrice` - Minimum price
- `maxPrice` - Maximum price
- `categoryId` - Filter by category
- `page` - Page number (default: 1)
- `pageSize` - Items per page (default: 20)

**Example URLs:**
```
GET /products
GET /products?region=HYD&minPrice=10&maxPrice=500
GET /products?categoryId=507f1f77bcf86cd799439011&page=1&pageSize=20
```

**Response:** Returns paginated list of products:
```json
{
  "success": true,
  "data": {
    "data": [
      {
        "id": "...",
        "name": "Product Name",
        "price": 99.99,
        "stock": 50,
        "images": ["url1", "url2"],
        "category": "Electronics"
      }
    ],
    "page": 1,
    "pageSize": 20,
    "totalItems": 100,
    "totalPages": 5
  }
}
```

---

### 1.5 Add to Cart

**Endpoint:** `POST /cart/items`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "productId": "507f1f77bcf86cd799439011",
  "quantity": 2
}
```

**Response:** Returns updated cart with items, subtotal, total.

---

### 1.6 Get Cart

**Endpoint:** `GET /cart`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:** Returns cart with all items and totals.

---

### 1.7 Create Order

**Endpoint:** `POST /orders`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body (with items):**
```json
{
  "items": [
    {
      "productId": "507f1f77bcf86cd799439011",
      "quantity": 2
    }
  ],
  "deliveryAddressId": "507f1f77bcf86cd799439012",
  "paymentMethod": "card",
  "scheduledDeliveryDate": "2024-12-25T10:00:00Z"
}
```

**Request Body (from cart - omit items):**
```json
{
  "deliveryAddressId": "507f1f77bcf86cd799439012",
  "paymentMethod": "cash_on_delivery"
}
```

**Response:** Returns created order with status "pending":
```json
{
  "success": true,
  "message": "Order created successfully",
  "data": {
    "id": "...",
    "items": [...],
    "totalAmount": 199.98,
    "status": "pending",
    "createdAt": "2024-11-21T..."
  }
}
```

---

### 1.8 Track Order

**Endpoint:** `GET /orders/:orderId/tracking`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:** Returns order tracking information with status timeline.

---

### 1.9 Get Customer Orders

**Endpoint:** `GET /orders`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `status` - Filter by status (pending, confirmed, processing, shipped, delivered, cancelled)

**Response:** Returns list of customer orders.

---

### 1.10 Add Review

**Endpoint:** `POST /reviews`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "productId": "507f1f77bcf86cd799439011",
  "rating": 5,
  "comment": "Great product! Highly recommended."
}
```

**Response:** Returns created review.

---

## 2. Retailer Flow

### 2.1 Signup + Login

**Signup Endpoint:** `POST /auth/signup`

**Request Body:**
```json
{
  "name": "Retail Store Owner",
  "email": "retailer@example.com",
  "phoneNumber": "+1234567891",
  "password": "password123",
  "role": "retailer",
  "businessName": "My Retail Store",
  "businessAddress": "123 Main St, City, State"
}
```

**Login:** Same as customer login (`POST /auth/login`).

---

### 2.2 Create Product

**Endpoint:** `POST /inventory/products`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "name": "Retail Product",
  "description": "Product description here",
  "price": 49.99,
  "stock": 100,
  "categoryId": "507f1f77bcf86cd799439011",
  "images": ["https://example.com/image1.jpg"],
  "weight": 0.5,
  "region": "HYD",
  "isLocal": true
}
```

**Response:** Returns created product.

---

### 2.3 Import Product from Wholesaler (Proxy Inventory)

**Endpoint:** `POST /inventory/import-from-wholesaler`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "productId": "507f1f77bcf86cd799439020",
  "stock": 50,
  "price": 45.99
}
```

**Note:** `productId` must be a wholesaler product. Retailer can override `stock` and `price`.

**Response:** Returns created proxy product with `sourceType: "wholesaler"`.

---

### 2.4 Get Inventory

**Endpoint:** `GET /inventory`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` - Page number
- `pageSize` - Items per page
- `sourceType` - Filter by source type ("retailer" or "wholesaler")

**Response:** Returns paginated list of retailer's products (both owned and imported).

---

### 2.5 View Retailer Dashboard

**Endpoint:** `GET /users/dashboard`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:** Returns dashboard data:
```json
{
  "success": true,
  "data": {
    "totalProducts": 50,
    "lowStockProducts": 5,
    "recentOrders": [...],
    "wholesaleOrders": [...],
    "revenueSummary": {
      "today": 1000,
      "thisMonth": 25000
    }
  }
}
```

---

### 2.6 View Customer Orders (Retailer)

**Endpoint:** `GET /retailers/orders/customers`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:** Returns list of customer orders for this retailer.

---

### 2.7 Update Order Status

**Endpoint:** `PATCH /orders/:orderId`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "status": "confirmed"
}
```

**Valid Status Values:** `pending`, `confirmed`, `processing`, `shipped`, `delivered`, `cancelled`

**Response:** Returns updated order.

---

## 3. Wholesaler Flow

### 3.1 Signup + Login

**Signup Endpoint:** `POST /auth/signup`

**Request Body:**
```json
{
  "name": "Wholesale Supplier",
  "email": "wholesaler@example.com",
  "phoneNumber": "+1234567892",
  "password": "password123",
  "role": "wholesaler",
  "businessName": "Wholesale Co.",
  "businessAddress": "456 Business Ave, City, State"
}
```

**Login:** Same as customer login (`POST /auth/login`).

---

### 3.2 Create Wholesale Product

**Endpoint:** `POST /inventory/products`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "name": "Wholesale Product",
  "description": "Bulk product for retailers",
  "price": 30.00,
  "stock": 1000,
  "categoryId": "507f1f77bcf86cd799439011",
  "images": ["https://example.com/image1.jpg"],
  "weight": 1.0,
  "region": "HYD",
  "isLocal": true
}
```

**Response:** Returns created product (automatically has `wholesalerId` set).

---

### 3.3 View Wholesaler Dashboard

**Endpoint:** `GET /users/dashboard`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:** Returns wholesaler dashboard data:
```json
{
  "success": true,
  "data": {
    "totalRetailersServed": 25,
    "wholesaleOrderStats": {
      "today": 5,
      "thisMonth": 120,
      "totalRevenue": 50000
    },
    "topSellingProducts": [...]
  }
}
```

---

### 3.4 View Wholesale Orders from Retailers

**Endpoint:** `GET /orders/wholesale/wholesaler`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:** Returns list of wholesale orders placed by retailers.

---

### 3.5 Update Wholesale Order Status

**Endpoint:** `PATCH /orders/:orderId`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "status": "confirmed"
}
```

**Response:** Returns updated wholesale order.

---

## 4. Common Endpoints

### 4.1 Health Check

**Endpoint:** `GET /health`

**No authentication required.**

**Response:**
```json
{
  "success": true,
  "message": "Service is healthy",
  "data": {
    "status": "ok",
    "timestamp": "2024-11-21T...",
    "environment": "development"
  }
}
```

---

### 4.2 Get Categories

**Endpoint:** `GET /categories`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:** Returns list of product categories.

---

### 4.3 Get Notifications

**Endpoint:** `GET /notifications`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:** Returns user notifications.

---

## How to Run Backend

### Prerequisites

- **Node.js** version 16+ (recommended: 18+)
- **MongoDB** installed and running locally, or MongoDB Atlas account

### Installation Steps

1. **Navigate to backend directory:**
   ```bash
   cd backend/nodejs
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Set up environment variables:**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` and fill in:
   - `MONGODB_URI` - Your MongoDB connection string
   - `JWT_SECRET` - A strong random secret (generate with: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`)
   - `JWT_REFRESH_SECRET` - Another strong random secret
   - `GOOGLE_MAPS_API_KEY` - If using location services
   - Other optional variables as needed

4. **Start MongoDB (if running locally):**
   ```bash
   # macOS (Homebrew)
   brew services start mongodb-community
   
   # Linux
   sudo systemctl start mongod
   
   # Windows
   # Start MongoDB service from Services panel
   ```

5. **Run the backend:**
   ```bash
   # Development mode (with auto-reload)
   npm run dev
   
   # Production mode
   npm start
   ```

6. **Run tests:**
   ```bash
   npm test
   ```

### Expected Output

When the server starts successfully, you should see:
```
=================================================
🚀 Backend Server Started Successfully!
=================================================
📡 Port: 3000
🌍 Environment: development
🗄️  Database: Connected to MongoDB

🔗 API Endpoints:
   Health Check: http://localhost:3000/health
   API Base URL: http://localhost:3000/v1
...
```

### Testing the API

1. **Health Check:**
   ```bash
   curl http://localhost:3000/health
   ```

2. **Use the provided `test.http` file** in VS Code/Cursor with REST Client extension for manual testing.

3. **Or use Postman/Insomnia** with the endpoints documented above.

### Troubleshooting

- **MongoDB Connection Error:** Ensure MongoDB is running and `MONGODB_URI` is correct.
- **Port Already in Use:** Change `PORT` in `.env` or stop the process using port 3000.
- **JWT Errors:** Ensure `JWT_SECRET` and `JWT_REFRESH_SECRET` are set and not empty.
- **Validation Errors:** Check request body matches the expected format (see examples above).

---

## API Response Format

All API responses follow this format:

**Success Response:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error message",
  "errors": [
    {
      "field": "fieldName",
      "message": "Field-specific error message"
    }
  ]
}
```

---

**For more details, see the API route definitions in `routes/` directory.**

