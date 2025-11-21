# Environment Variables Setup

## Quick Setup

1. **Create `.env` file:**
   ```bash
   cd backend/nodejs
   touch .env
   ```

2. **Copy the template below into `.env` and fill in your values:**

```bash
# ============================================
# Backend Environment Variables
# ============================================

# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
# Local MongoDB example:
MONGODB_URI=mongodb://127.0.0.1:27017/oops_project_dev
# MongoDB Atlas example:
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/dbname

# JWT Authentication
# Generate strong secrets:
# node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
JWT_SECRET=your-secret-key-change-in-production
JWT_REFRESH_SECRET=your-refresh-secret-key-change-in-production
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d

# OTP Configuration
OTP_EXPIRY_MINUTES=10

# Third-Party Services
GOOGLE_MAPS_API_KEY=your-google-maps-api-key-here

# CORS Configuration
# Comma-separated list of allowed origins
# Leave empty for development (allows all origins)
ALLOWED_ORIGINS=

# API Configuration (Optional)
API_BASE_URL=http://localhost:3000/v1
API_TIMEOUT=30000
```

## Required Variables

- `MONGODB_URI` - MongoDB connection string
- `JWT_SECRET` - Secret for JWT access tokens
- `JWT_REFRESH_SECRET` - Secret for JWT refresh tokens

## Optional Variables

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development, production, test)
- `GOOGLE_MAPS_API_KEY` - For location services
- `ALLOWED_ORIGINS` - CORS allowed origins
- `OTP_EXPIRY_MINUTES` - OTP expiration time (default: 10)

## Generate Secure Secrets

```bash
# Generate JWT_SECRET
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Generate JWT_REFRESH_SECRET
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

## Test Database

For running tests, you can use a separate test database:
```bash
MONGODB_URI=mongodb://localhost:27017/ecommerce_test_db
```

Or set it in the test environment:
```bash
NODE_ENV=test MONGODB_URI=mongodb://localhost:27017/ecommerce_test_db npm test
```

