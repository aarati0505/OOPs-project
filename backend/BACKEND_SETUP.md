# Backend Server Setup Guide

This guide shows you exactly where to implement the backend APIs that connect to your Flutter frontend.

## Quick Start

### Option 1: Node.js + Express + MongoDB

1. **Setup:**
```bash
cd backend/nodejs
npm install
cp .env.example .env
# Edit .env with your database credentials
```

2. **Start Server:**
```bash
npm run dev  # Development mode
npm start    # Production mode
```

3. **Update Flutter API URL:**
Edit `lib/core/constants/app_constants.dart`:
```dart
static const String apiBaseUrl = 'http://localhost:3000/v1';
// Or for production: 'https://api.yourdomain.com/v1'
```

### Option 2: Python + Flask + PostgreSQL

1. **Setup:**
```bash
cd backend/python
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your database credentials
```

2. **Start Server:**
```bash
python app.py
```

---

## File Structure Overview

```
backend/
├── nodejs/ (or python/)
│   ├── server.js (or app.py)          ← Main server file
│   ├── routes/                         ← API endpoint definitions
│   │   ├── auth.routes.js             ← /v1/auth/* endpoints
│   │   ├── products.routes.js         ← /v1/products/* endpoints
│   │   ├── orders.routes.js           ← /v1/orders/* endpoints
│   │   ├── inventory.routes.js        ← /v1/inventory/* endpoints
│   │   └── ...
│   ├── controllers/                    ← Business logic implementation
│   │   ├── auth.controller.js         ← Login, signup logic
│   │   ├── products.controller.js     ← Product queries, filters
│   │   ├── orders.controller.js       ← Order creation, tracking
│   │   └── ...
│   ├── models/                         ← Database models/schemas
│   │   ├── User.js                    ← User model
│   │   ├── Product.js                 ← Product model
│   │   ├── Order.js                   ← Order model
│   │   └── ...
│   ├── middleware/                     ← Auth, error handling
│   │   ├── auth.middleware.js         ← JWT token validation
│   │   └── errorHandler.middleware.js ← Error responses
│   └── config/
│       └── database.js                 ← Database connection
```

---

## Endpoint Mapping

All endpoints in your backend should match the paths in `lib/core/constants/app_constants.dart`:

| Flutter Constant | Backend Route | File |
|-----------------|---------------|------|
| `loginEndpoint` | `POST /v1/auth/login` | `routes/auth.routes.js` |
| `signupEndpoint` | `POST /v1/auth/signup` | `routes/auth.routes.js` |
| `productsEndpoint` | `GET /v1/products` | `routes/products.routes.js` |
| `createOrderEndpoint` | `POST /v1/orders` | `routes/orders.routes.js` |
| `inventoryEndpoint` | `GET /v1/inventory` | `routes/inventory.routes.js` |
| ... | ... | ... |

---

## Response Format

**All endpoints must return this format to match Flutter `ApiResponse`:**
```json
{
  "success": true,
  "message": "Optional message",
  "data": {...},
  "errors": [...] // Only if success: false
}
```

**Paginated responses must include:**
```json
{
  "success": true,
  "data": {
    "data": [...items...],
    "currentPage": 1,
    "totalPages": 10,
    "totalItems": 200,
    "pageSize": 20,
    "hasNext": true,
    "hasPrevious": false
  }
}
```

---

## Authentication Flow

1. **Flutter sends:** `POST /v1/auth/login` with `{emailOrPhone, password}`
2. **Backend verifies** credentials and returns `{user, accessToken, refreshToken}`
3. **Flutter stores** token and includes in headers: `Authorization: Bearer <token>`
4. **Backend validates** token via `auth.middleware.js` on protected routes

---

## Database Schema

You'll need these collections/tables:

- **Users** (customers, retailers, wholesalers)
- **Products** (with retailerId, wholesalerId relationships)
- **Orders** (customer → retailer, retailer → wholesaler)
- **Cart Items** (temporary or persisted)
- **Reviews** (product feedback)
- **Addresses** (user delivery addresses)
- **Notifications** (order updates, etc.)

---

## Next Steps

1. Choose your stack (Node.js or Python)
2. Setup database (MongoDB, PostgreSQL, or Firestore)
3. Implement routes and controllers (see example files)
4. Update `AppConstants.apiBaseUrl` in Flutter
5. Test endpoints using Postman or curl
6. Connect Flutter app to backend

See individual route and controller files for detailed implementation examples!

