# Node.js + Express Backend

This backend implementation matches the Dart API client contracts defined in `lib/core/api/`.

## Structure

```
backend/nodejs/
├── app.js                    # Express application setup
├── server.js                 # Server startup
├── package.json              # Dependencies
├── .env.example              # Environment variables template
│
├── config/
│   ├── constants.js          # API constants (matching Dart AppConstants)
│   └── database.js           # Database connection (TODO)
│
├── routes/
│   ├── index.js              # Route aggregator
│   ├── auth.routes.js        # Authentication routes
│   ├── user.routes.js        # User/profile routes
│   ├── product.routes.js     # Product routes
│   ├── order.routes.js        # Order routes
│   ├── cart.routes.js        # Cart routes
│   ├── inventory.routes.js   # Inventory routes
│   ├── category.routes.js    # Category routes
│   ├── review.routes.js      # Review routes
│   ├── location.routes.js    # Location routes
│   ├── notification.routes.js # Notification routes
│   ├── retailer.routes.js    # Retailer-specific routes
│   └── wholesaler.routes.js  # Wholesaler-specific routes
│
├── controllers/
│   ├── auth.controller.js    # Authentication logic
│   ├── user.controller.js    # User management
│   ├── product.controller.js # Product operations
│   ├── order.controller.js   # Order management
│   ├── cart.controller.js    # Cart operations
│   ├── inventory.controller.js # Inventory management
│   ├── category.controller.js # Category operations
│   ├── review.controller.js  # Review operations
│   ├── location.controller.js # Location services
│   └── notification.controller.js # Notification management
│
├── models/                   # Database models (skeletons)
│   ├── User.js
│   ├── Product.js
│   ├── Order.js
│   ├── Cart.js
│   ├── Category.js
│   ├── Review.js
│   ├── Address.js
│   └── Notification.js
│
├── middleware/
│   ├── auth.middleware.js    # JWT authentication
│   ├── validation.middleware.js # Request validation
│   ├── error.middleware.js   # Error handling
│   └── role.middleware.js    # Role-based access control
│
├── services/                 # Business logic services
│   ├── auth.service.js      # Authentication services
│   ├── email.service.js     # Email sending
│   ├── sms.service.js       # SMS sending
│   ├── payment.service.js   # Payment processing
│   └── notification.service.js # Notification sending
│
└── utils/
    ├── response.util.js      # API response helpers
    ├── pagination.util.js    # Pagination helpers
    └── error.util.js         # Error handling utilities
```

## Setup

1. Install dependencies:
```bash
cd backend/nodejs
npm install
```

2. Copy `.env.example` to `.env` and configure:
```bash
cp .env.example .env
```

3. Start the server:
```bash
npm start
# or for development with auto-reload:
npm run dev
```

## API Base URL

The API is available at: `http://localhost:3000/v1`

This matches the Dart `AppConstants.apiBaseUrl` structure.

## Current Status

- ✅ All routes and controllers created with mock responses
- ✅ Response structure matches Dart `ApiResponse` and `PaginatedResponse`
- ✅ All endpoints match Dart API service methods
- ⏳ Database integration (TODO)
- ⏳ Authentication implementation (TODO)
- ⏳ Business logic implementation (TODO)

## Example API Calls

### Health Check
```bash
GET http://localhost:3000/health
```

### Login
```bash
POST http://localhost:3000/v1/auth/login
Content-Type: application/json

{
  "emailOrPhone": "user@example.com",
  "password": "password123"
}
```

### Get Products
```bash
GET http://localhost:3000/v1/products?page=1&pageSize=20
Authorization: Bearer <token>
```

## Next Steps

1. Implement database models (MongoDB/PostgreSQL)
2. Implement JWT authentication
3. Implement business logic in controllers
4. Add request validation
5. Add error handling improvements
6. Add logging
7. Add tests

