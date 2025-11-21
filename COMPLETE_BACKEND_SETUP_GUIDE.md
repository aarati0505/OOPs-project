# Complete Backend Setup Guide

## Overview
This guide covers setting up all backend modules for your e-commerce application with customer, retailer, and wholesaler roles.

## Required External Services & API Keys

### 1. Google OAuth (Social Login)
**Purpose**: Google Sign-In for users

**Setup Steps:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable "Google+ API" and "Google OAuth2 API"
4. Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client ID"
5. Configure OAuth consent screen
6. Create credentials for:
   - **Web application** (for backend)
   - **Android** (for Flutter app)
   - **iOS** (for Flutter app)

**Get these values:**
```
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
```

### 2. Twilio (SMS/OTP)
**Purpose**: Send OTP via SMS for phone verification

**Setup Steps:**
1. Sign up at [Twilio](https://www.twilio.com/)
2. Get a phone number (free trial available)
3. Get your credentials from dashboard

**Get these values:**
```
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your-auth-token
TWILIO_PHONE_NUMBER=+1234567890
```

**Alternative (Free for testing): Firebase Phone Auth**
- No cost for development
- Built into Firebase

### 3. Google Maps API (Location Services)
**Purpose**: Location-based shop listings, distance calculation

**Setup Steps:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable these APIs:
   - Maps JavaScript API
   - Geocoding API
   - Distance Matrix API
   - Places API
3. Create API key in "Credentials"
4. Restrict key to your domain/app

**Get this value:**
```
GOOGLE_MAPS_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### 4. SendGrid or Mailgun (Email)
**Purpose**: Order confirmations, delivery notifications

**Option A: SendGrid (Recommended)**
1. Sign up at [SendGrid](https://sendgrid.com/)
2. Free tier: 100 emails/day
3. Create API key

```
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxx
SENDGRID_FROM_EMAIL=noreply@yourdomain.com
```

**Option B: Mailgun**
1. Sign up at [Mailgun](https://www.mailgun.com/)
2. Free tier: 5,000 emails/month

```
MAILGUN_API_KEY=your-api-key
MAILGUN_DOMAIN=mg.yourdomain.com
```

### 5. Firebase (Optional but Recommended)
**Purpose**: Push notifications, phone auth, real-time updates

**Setup Steps:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create project
3. Add Android/iOS apps
4. Download config files
5. Enable Authentication, Firestore, Cloud Messaging

**Get these values:**
```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-service-account@project.iam.gserviceaccount.com
```

### 6. Razorpay/Stripe (Payment Gateway)
**Purpose**: Online payment processing

**Option A: Razorpay (India)**
```
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxxx
RAZORPAY_KEY_SECRET=your-secret-key
```

**Option B: Stripe (International)**
```
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxx
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxx
```

## Updated .env File

Here's the complete `.env` file with all required configurations:

```bash
# ============================================
# Backend Environment Variables - COMPLETE
# ============================================

# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
MONGODB_URI=mongodb://localhost:27017/ecommerce_db

# JWT Authentication
JWT_SECRET=d49f405eab13e6c76def70ac6d71b11ee3d67087eeae877590858209c745d821
JWT_REFRESH_SECRET=2514c6924d15c217abd9d93a47be8f95b366ec304c6c0b0a54abe03e093f1838
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d

# OTP Configuration
OTP_EXPIRY_MINUTES=10

# ============================================
# EXTERNAL SERVICES (Add your keys below)
# ============================================

# Google OAuth (Social Login)
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Twilio (SMS/OTP)
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your-twilio-auth-token
TWILIO_PHONE_NUMBER=+1234567890

# Google Maps API (Location Services)
GOOGLE_MAPS_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# SendGrid (Email Notifications)
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxx
SENDGRID_FROM_EMAIL=noreply@yourdomain.com
SENDGRID_FROM_NAME=YourAppName

# Firebase (Push Notifications & Phone Auth)
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY=your-firebase-private-key
FIREBASE_CLIENT_EMAIL=your-service-account@project.iam.gserviceaccount.com

# Payment Gateway (Choose one)
# Razorpay
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxxx
RAZORPAY_KEY_SECRET=your-razorpay-secret

# Stripe
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxx
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxx

# CORS Configuration
ALLOWED_ORIGINS=

# API Configuration
API_BASE_URL=http://localhost:3000/v1
API_TIMEOUT=30000

# File Upload (Optional)
MAX_FILE_SIZE=5242880
UPLOAD_DIR=./uploads
```

## Database Schema Setup

### Collections Needed:

1. **users** - Customer, Retailer, Wholesaler accounts
2. **products** - Product catalog
3. **inventory** - Stock management per retailer/wholesaler
4. **orders** - Customer orders
5. **wholesale_orders** - Retailer orders from wholesalers
6. **cart** - Shopping cart items
7. **categories** - Product categories
8. **reviews** - Product reviews and ratings
9. **notifications** - User notifications
10. **addresses** - Delivery addresses
11. **otps** - OTP verification codes

### Sample Data Structure:

**Users Collection:**
```json
{
  "_id": "ObjectId",
  "name": "John Doe",
  "email": "john@example.com",
  "phoneNumber": "+1234567890",
  "password": "hashed_password",
  "role": "customer|retailer|wholesaler",
  "businessName": "Store Name",
  "businessAddress": "123 Main St",
  "location": {
    "type": "Point",
    "coordinates": [longitude, latitude],
    "address": "Full address"
  },
  "isEmailVerified": true,
  "isPhoneVerified": true,
  "createdAt": "ISODate",
  "lastLoginAt": "ISODate"
}
```

**Products Collection:**
```json
{
  "_id": "ObjectId",
  "name": "Product Name",
  "description": "Product description",
  "category": "ObjectId (ref: categories)",
  "price": 99.99,
  "images": ["url1", "url2"],
  "unit": "kg|piece|liter",
  "ownerId": "ObjectId (ref: users)",
  "ownerRole": "retailer|wholesaler",
  "isActive": true,
  "createdAt": "ISODate"
}
```

**Inventory Collection:**
```json
{
  "_id": "ObjectId",
  "productId": "ObjectId (ref: products)",
  "ownerId": "ObjectId (ref: users)",
  "quantity": 100,
  "minQuantity": 10,
  "maxQuantity": 1000,
  "availableFrom": "ISODate",
  "isAvailable": true,
  "proxyAvailable": true,
  "wholesalerId": "ObjectId (ref: users)",
  "updatedAt": "ISODate"
}
```

**Orders Collection:**
```json
{
  "_id": "ObjectId",
  "orderNumber": "ORD-2024-001",
  "customerId": "ObjectId (ref: users)",
  "retailerId": "ObjectId (ref: users)",
  "items": [
    {
      "productId": "ObjectId",
      "name": "Product Name",
      "quantity": 2,
      "price": 99.99,
      "total": 199.98
    }
  ],
  "totalAmount": 199.98,
  "status": "pending|confirmed|processing|shipped|delivered|cancelled",
  "paymentMethod": "online|offline",
  "paymentStatus": "pending|paid|failed",
  "deliveryAddress": {
    "street": "123 Main St",
    "city": "City",
    "state": "State",
    "zipCode": "12345",
    "coordinates": [longitude, latitude]
  },
  "deliveryDate": "ISODate",
  "isOfflineOrder": false,
  "reminderSent": false,
  "trackingInfo": {
    "status": "Order placed",
    "updatedAt": "ISODate"
  },
  "createdAt": "ISODate",
  "updatedAt": "ISODate"
}
```

## Module Implementation Checklist

### ✅ Module 1: Registration and Sign-Up
- [x] Multi-role registration (Customer/Retailer/Wholesaler)
- [ ] OTP via SMS (Twilio integration needed)
- [ ] Google Sign-In (Google OAuth needed)
- [ ] Facebook Sign-In (Facebook OAuth needed)
- [ ] Location capture during registration

**Required APIs:**
- Twilio for SMS OTP
- Google OAuth for social login
- Google Maps for location

### ✅ Module 2: User Dashboards
- [x] Role-based dashboards
- [ ] Category-wise item listing
- [ ] Product images storage
- [ ] Proxy availability (retailer showing wholesaler items)
- [ ] Stock status display

**Required:**
- Image storage (AWS S3 or local storage)
- Database queries for inventory

### ⚠️ Module 3: Search & Navigation
- [ ] Smart filtering (price, quantity, stock)
- [ ] Location-based shop listings
- [ ] Distance calculation
- [ ] Nearby shops finder

**Required APIs:**
- Google Maps Distance Matrix API
- Google Places API

### ⚠️ Module 4: Order & Payment Management
- [ ] Online order placement
- [ ] Offline order with calendar
- [ ] Order tracking
- [ ] Automatic stock updates
- [ ] Payment gateway integration

**Required APIs:**
- Razorpay/Stripe for payments
- Calendar API for reminders
- SMS/Email for notifications

### ⚠️ Module 5: Feedback & Dashboard Updates
- [ ] Real-time order status
- [ ] SMS/Email delivery confirmation
- [ ] Product feedback collection
- [ ] Feedback display on products

**Required APIs:**
- SendGrid/Mailgun for emails
- Twilio for SMS
- WebSocket for real-time updates

## Quick Start Commands

### 1. Install Additional Dependencies
```bash
cd backend/nodejs
npm install twilio @sendgrid/mail firebase-admin googleapis stripe razorpay
```

### 2. Seed Database with Sample Data
```bash
npm run seed
```

### 3. Start Server
```bash
npm start
```

## Testing Without External APIs

For development/testing without external services:

1. **OTP**: Use mock OTP (any 4 digits work)
2. **SMS**: Log to console instead of sending
3. **Email**: Log to console instead of sending
4. **Payment**: Use test mode
5. **Location**: Use mock coordinates

## Cost Breakdown (Free Tiers)

| Service | Free Tier | Cost After |
|---------|-----------|------------|
| Twilio | $15 credit | $0.0075/SMS |
| SendGrid | 100 emails/day | $19.95/month |
| Google Maps | $200 credit/month | Pay as you go |
| Firebase | Generous free tier | Pay as you go |
| MongoDB Atlas | 512MB free | $9/month |
| Razorpay | No setup fee | 2% per transaction |

**Total Monthly Cost (Starting):** $0 - $50 depending on usage

## Next Steps

1. **Get API Keys**: Sign up for services and get credentials
2. **Update .env**: Add all API keys to `.env` file
3. **Install Dependencies**: Run npm install for new packages
4. **Seed Database**: Add sample products and users
5. **Test APIs**: Use Postman/Thunder Client to test endpoints
6. **Integrate Frontend**: Update Flutter app to use APIs

## Priority Order

**Phase 1 (Essential):**
1. ✅ Basic authentication (done)
2. Database with sample products
3. Order placement
4. Stock management

**Phase 2 (Important):**
1. SMS OTP (Twilio)
2. Location services (Google Maps)
3. Email notifications (SendGrid)

**Phase 3 (Enhanced):**
1. Google Sign-In
2. Payment gateway
3. Real-time tracking
4. Push notifications

Would you like me to:
1. Create database seed scripts with sample data?
2. Set up specific API integrations?
3. Create detailed API documentation?
