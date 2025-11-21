# Database Implementation Summary

## Overview

All mock logic has been replaced with real MongoDB + Mongoose database implementations. All controllers now use actual database operations while maintaining the exact API contracts matching the Dart client.

## Controllers with Real DB Logic

### ✅ All Controllers Implemented:

1. **auth.controller.js** - Authentication (signup, login, OTP, password reset, refresh token)
2. **user.controller.js** - User profile and address management
3. **product.controller.js** - Product listing, search, filtering with region support
4. **inventory.controller.js** - Retailer/wholesaler inventory management
5. **category.controller.js** - Category operations
6. **order.controller.js** - Order creation, tracking, status updates
7. **cart.controller.js** - Cart operations with stock validation
8. **review.controller.js** - Review CRUD with automatic product rating updates
9. **notification.controller.js** - Notification management
10. **location.controller.js** - Location-based services (nearby shops, distance calculation)

## Models with Real Schemas

All models now have proper Mongoose schemas:

1. **User** - Authentication, roles, addresses, location
2. **Product** - Products with category, retailer/wholesaler ownership, region support
3. **Category** - Product categories
4. **Order** - Orders with items, tracking, status
5. **Cart** - Shopping cart with items
6. **Review** - Product reviews with automatic rating calculation
7. **Address** - User addresses
8. **Notification** - User notifications

## Example Flows

### Flow 1: Signup → Login → Add Product as Retailer → Place Order as Customer

#### 1. Retailer Signup
```bash
POST /v1/auth/signup
{
  "name": "Retailer Name",
  "email": "retailer@example.com",
  "phoneNumber": "1234567890",
  "password": "password123",
  "role": "retailer",
  "businessName": "My Shop",
  "location": { "city": "City", "region": "Region", "lat": 12.34, "lng": 56.78 }
}
```

**Functions involved:**
- `auth.controller.signup()` → Creates User in DB with hashed password
- `auth.service.hashPassword()` → Bcrypt password hashing
- `auth.service.generateAccessToken()` → JWT token generation

#### 2. Retailer Login
```bash
POST /v1/auth/login
{
  "emailOrPhone": "retailer@example.com",
  "password": "password123"
}
```

**Functions involved:**
- `auth.controller.login()` → Finds user, verifies password
- `auth.service.comparePassword()` → Bcrypt password verification
- Updates `User.lastLoginAt` in DB

#### 3. Add Product to Inventory
```bash
POST /v1/inventory/products
Authorization: Bearer <retailer_token>
{
  "name": "Product Name",
  "description": "Description",
  "price": 99.99,
  "stock": 100,
  "categoryId": "<category_id>",
  "images": ["url1", "url2"],
  "region": "Region",
  "isLocal": true
}
```

**Functions involved:**
- `inventory.controller.addProduct()` → Creates Product in DB
- Sets `retailerId` from authenticated user
- Updates `Category.productCount` in DB

#### 4. Customer Signup & Login
```bash
POST /v1/auth/signup
{
  "name": "Customer Name",
  "email": "customer@example.com",
  "phoneNumber": "9876543210",
  "password": "password123",
  "role": "customer"
}
```

#### 5. Add Product to Cart
```bash
POST /v1/cart/items
Authorization: Bearer <customer_token>
{
  "productId": "<product_id>",
  "quantity": 2
}
```

**Functions involved:**
- `cart.controller.addToCart()` → Finds/creates Cart, adds item
- Validates product stock in DB
- Calculates cart totals

#### 6. Create Order
```bash
POST /v1/orders
Authorization: Bearer <customer_token>
{
  "deliveryAddressId": "<address_id>",
  "paymentMethod": "card"
}
```

**Functions involved:**
- `order.controller.createOrder()` → Creates Order from cart
- Validates all products and stock
- Updates Product stock in DB
- Creates Notification for retailer
- Clears Cart

---

### Flow 2: Get Products with Region Filtering

#### 1. Get Products (with user location)
```bash
GET /v1/products?page=1&pageSize=20&region=Region
Authorization: Bearer <token>
```

**Functions involved:**
- `product.controller.getProducts()` → Queries Product collection
- Filters by `user.location.region` if user has location
- Returns local products matching user's region
- Uses pagination from DB

---

### Flow 3: Review Product

#### 1. Create Review
```bash
POST /v1/reviews
Authorization: Bearer <customer_token>
{
  "productId": "<product_id>",
  "orderId": "<order_id>",
  "rating": 5,
  "comment": "Great product!"
}
```

**Functions involved:**
- `review.controller.createReview()` → Creates Review in DB
- `Review.post('save')` hook → Automatically updates Product.rating and Product.reviewCount
- Prevents duplicate reviews (one per user per product)

## Commands to Run Backend

### 1. Install Dependencies

```bash
cd backend/nodejs
npm install
```

This installs:
- `mongoose` - MongoDB ODM
- `bcryptjs` - Password hashing
- `jsonwebtoken` - JWT tokens
- `express`, `dotenv`, `cors` - Already present

### 2. Setup Environment Variables

Create `.env` file:
```bash
cp .env.example .env
```

Edit `.env`:
```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/ecommerce_db
JWT_SECRET=your-secret-key-change-in-production
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d
```

### 3. Start MongoDB

**Option A: Local MongoDB**
```bash
# macOS (using Homebrew)
brew services start mongodb-community

# Linux
sudo systemctl start mongod

# Or run MongoDB in Docker
docker run -d -p 27017:27017 --name mongodb mongo:latest
```

**Option B: MongoDB Atlas (Cloud)**
- Update `MONGODB_URI` in `.env` with your Atlas connection string

### 4. Start the Server

```bash
# Production
npm start

# Development (with auto-reload)
npm run dev
```

### 5. Verify Setup

```bash
# Health check
curl http://localhost:3000/health

# Test signup
curl -X POST http://localhost:3000/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phoneNumber": "1234567890",
    "password": "test123",
    "role": "customer"
  }'
```

## Database Schema Summary

### User
- Authentication: email, phone, passwordHash
- Role: customer | retailer | wholesaler
- Location: city, region, lat, lng
- Business info for retailer/wholesaler

### Product
- Basic: name, description, price, stock
- Ownership: retailerId, wholesalerId
- Location: region, isLocal
- Category: categoryId (reference)
- Images: array of URLs

### Order
- User: userId, retailerId, wholesalerId
- Items: array with productId, quantity, price (snapshot)
- Status: pending → confirmed → processing → shipped → delivered
- Tracking: trackingInfo array, trackingNumber
- Payment: paymentMethod, paymentStatus

### Cart
- User: userId (unique)
- Items: array with productId, quantity

### Review
- User: userId, productId (unique constraint)
- Rating: 1-5, comment
- Auto-updates Product.rating via hooks

## Key Features Implemented

1. ✅ **Authentication**: JWT-based with refresh tokens
2. ✅ **Role-based Access**: customer, retailer, wholesaler
3. ✅ **Location-based Products**: Region filtering, local products
4. ✅ **Stock Management**: Real-time stock updates
5. ✅ **Order Processing**: Cart to order conversion, stock deduction
6. ✅ **Review System**: Automatic product rating calculation
7. ✅ **Notifications**: Order status updates, new orders
8. ✅ **Pagination**: All list endpoints support pagination
9. ✅ **Error Handling**: Consistent error responses matching Dart structure

## Next Steps (Optional Enhancements)

1. Add OTP verification service (SMS/Email)
2. Implement payment gateway integration
3. Add image upload functionality
4. Implement advanced geo-queries (MongoDB geospatial indexes)
5. Add caching layer (Redis)
6. Add logging and monitoring
7. Add API rate limiting
8. Add request validation middleware (Joi/express-validator)

