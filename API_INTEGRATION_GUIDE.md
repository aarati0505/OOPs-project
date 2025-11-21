# API Integration Guide - Complete Setup

## ✅ What's Already Done

### 1. Backend Server
- ✅ Running on http://localhost:3000
- ✅ MongoDB connected
- ✅ Database seeded with sample data:
  - 8 Categories
  - 4 Users (1 customer, 2 retailers, 1 wholesaler)
  - 26 Products with stock

### 2. Test Credentials
```
Customer:   customer@test.com / password123
Retailer:   retailer@test.com / password123
Wholesaler: wholesaler@test.com / password123
Retailer 2: retailer2@test.com / password123
```

## 🔑 Required API Keys & Setup

### Priority 1: Essential for Basic Functionality

#### 1. SMS/OTP Service (Choose One)

**Option A: Twilio (Recommended)**
- Sign up: https://www.twilio.com/try-twilio
- Free trial: $15 credit
- Cost: $0.0075 per SMS

```bash
# Add to backend/nodejs/.env
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your-auth-token
TWILIO_PHONE_NUMBER=+1234567890
```

**Option B: Firebase Phone Auth (Free)**
- Already have Firebase? Use Phone Authentication
- No SMS costs during development
- Setup: https://firebase.google.com/docs/auth/web/phone-auth

```bash
# Add to backend/nodejs/.env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-service-account@project.iam.gserviceaccount.com
```

#### 2. Email Service (Choose One)

**Option A: SendGrid (Recommended)**
- Sign up: https://sendgrid.com/
- Free tier: 100 emails/day
- Easy setup

```bash
# Add to backend/nodejs/.env
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxx
SENDGRID_FROM_EMAIL=noreply@yourdomain.com
SENDGRID_FROM_NAME=YourAppName
```

**Option B: Mailgun**
- Sign up: https://www.mailgun.com/
- Free tier: 5,000 emails/month

```bash
# Add to backend/nodejs/.env
MAILGUN_API_KEY=your-api-key
MAILGUN_DOMAIN=mg.yourdomain.com
```

### Priority 2: Important for Full Features

#### 3. Google Maps API (Location Services)
- Console: https://console.cloud.google.com/
- Enable APIs:
  - Maps JavaScript API
  - Geocoding API
  - Distance Matrix API
  - Places API

```bash
# Add to backend/nodejs/.env
GOOGLE_MAPS_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**Cost**: $200 free credit per month

#### 4. Google OAuth (Social Login)
- Console: https://console.cloud.google.com/
- Create OAuth 2.0 credentials
- Configure consent screen

```bash
# Add to backend/nodejs/.env
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
```

### Priority 3: Enhanced Features

#### 5. Payment Gateway (Choose One)

**Option A: Razorpay (India)**
- Sign up: https://razorpay.com/
- Test mode available

```bash
# Add to backend/nodejs/.env
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxxx
RAZORPAY_KEY_SECRET=your-secret-key
```

**Option B: Stripe (International)**
- Sign up: https://stripe.com/
- Test mode available

```bash
# Add to backend/nodejs/.env
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxx
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxx
```

## 📦 Install Additional Dependencies

```bash
cd backend/nodejs

# For SMS (Twilio)
npm install twilio

# For Email (SendGrid)
npm install @sendgrid/mail

# For Firebase
npm install firebase-admin

# For Google APIs
npm install googleapis

# For Payment (choose one)
npm install stripe
# OR
npm install razorpay
```

## 🧪 Testing the API

### 1. Test Health Check
```bash
curl http://localhost:3000/health
```

### 2. Test Login
```bash
curl -X POST http://localhost:3000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "retailer@test.com",
    "password": "password123"
  }'
```

### 3. Test Get Products
```bash
curl http://localhost:3000/v1/products
```

### 4. Test Get Categories
```bash
curl http://localhost:3000/v1/categories
```

## 🔄 Module Implementation Status

### Module 1: Registration & Sign-Up
- ✅ Multi-role registration (Customer/Retailer/Wholesaler)
- ✅ Basic authentication
- ⚠️ OTP via SMS (needs Twilio/Firebase setup)
- ⚠️ Google Sign-In (needs Google OAuth setup)
- ⚠️ Location capture (needs Google Maps API)

**To Enable:**
1. Add Twilio or Firebase credentials to `.env`
2. Add Google OAuth credentials to `.env`
3. Add Google Maps API key to `.env`
4. Restart backend server

### Module 2: User Dashboards
- ✅ Role-based dashboards (Frontend)
- ✅ Category-wise item listing
- ✅ Product data with stock
- ✅ Retailer/Wholesaler products
- ⚠️ Image upload (needs storage setup)

**To Enable:**
- For local storage: Already works
- For cloud storage (AWS S3): Add AWS credentials

### Module 3: Search & Navigation
- ✅ Basic product search
- ✅ Category filtering
- ⚠️ Location-based shop listings (needs Google Maps API)
- ⚠️ Distance calculation (needs Google Maps API)

**To Enable:**
1. Add Google Maps API key to `.env`
2. Restart backend server

### Module 4: Order & Payment Management
- ✅ Order creation
- ✅ Order tracking
- ✅ Stock updates
- ⚠️ Online payment (needs Razorpay/Stripe)
- ⚠️ Calendar integration (needs implementation)
- ⚠️ SMS notifications (needs Twilio)

**To Enable:**
1. Add payment gateway credentials to `.env`
2. Add Twilio credentials for SMS
3. Restart backend server

### Module 5: Feedback & Dashboard Updates
- ✅ Order status updates
- ✅ Product reviews
- ⚠️ SMS delivery confirmation (needs Twilio)
- ⚠️ Email notifications (needs SendGrid/Mailgun)
- ⚠️ Real-time updates (needs WebSocket implementation)

**To Enable:**
1. Add SendGrid/Mailgun credentials to `.env`
2. Add Twilio credentials for SMS
3. Restart backend server

## 🚀 Quick Start (Without External APIs)

You can test the app without external APIs using mock implementations:

### 1. Mock OTP (Already Implemented)
- Any 4-digit code works
- No SMS sent

### 2. Mock Email
- Logs to console instead of sending
- Check backend logs

### 3. Mock Payment
- Use test mode
- No actual charges

### 4. Mock Location
- Use hardcoded coordinates
- No Google Maps API needed

## 📱 Flutter App Configuration

### Update API Base URL

For Android Emulator:
```dart
// lib/core/constants/app_constants.dart
static const String apiBaseUrl = 'http://10.0.2.2:3000/v1';
```

For iOS Simulator:
```dart
static const String apiBaseUrl = 'http://localhost:3000/v1';
```

For Physical Device (same network):
```dart
static const String apiBaseUrl = 'http://YOUR_COMPUTER_IP:3000/v1';
// Example: 'http://192.168.1.100:3000/v1'
```

### Test the Connection

```dart
// Test in your Flutter app
final response = await http.get(
  Uri.parse('http://10.0.2.2:3000/health'),
);
print(response.body);
```

## 🔧 Troubleshooting

### Backend Not Responding
```bash
# Check if server is running
curl http://localhost:3000/health

# Check backend logs
# Look at the terminal where you ran npm start
```

### Database Connection Failed
```bash
# Check MongoDB is running
# Windows: Check Services for MongoDB
# Mac/Linux: sudo systemctl status mongod

# Check connection string in .env
MONGODB_URI=mongodb://localhost:27017/ecommerce_db
```

### Flutter Can't Connect to Backend
```bash
# For Android Emulator, use:
http://10.0.2.2:3000/v1

# For iOS Simulator, use:
http://localhost:3000/v1

# For Physical Device, use your computer's IP:
http://192.168.1.XXX:3000/v1
```

## 📊 Database Management

### View Data
```bash
# Connect to MongoDB
mongosh

# Switch to database
use ecommerce_db

# View collections
show collections

# View users
db.users.find().pretty()

# View products
db.products.find().pretty()

# View categories
db.categories.find().pretty()
```

### Re-seed Database
```bash
cd backend/nodejs
npm run seed
```

### Clear Database
```bash
mongosh
use ecommerce_db
db.dropDatabase()
```

## 🎯 Next Steps

### Phase 1: Get Basic Features Working (No External APIs)
1. ✅ Backend running
2. ✅ Database seeded
3. ✅ Flutter app connected
4. Test login with seeded users
5. Test product listing
6. Test order placement

### Phase 2: Add Essential APIs
1. Add Twilio for SMS OTP
2. Add SendGrid for emails
3. Test complete signup flow
4. Test order notifications

### Phase 3: Add Enhanced Features
1. Add Google Maps for location
2. Add Google OAuth for social login
3. Add payment gateway
4. Test complete user journey

## 💰 Cost Estimate

| Service | Free Tier | Monthly Cost (After Free) |
|---------|-----------|---------------------------|
| MongoDB Atlas | 512MB | $0 (sufficient for testing) |
| Twilio | $15 credit | ~$5-10 (100-200 SMS) |
| SendGrid | 100 emails/day | $0 (sufficient for testing) |
| Google Maps | $200 credit/month | $0 (sufficient for testing) |
| Firebase | Generous free tier | $0 (sufficient for testing) |
| Razorpay/Stripe | No setup fee | 2% per transaction |

**Total for Development/Testing: $0-5/month**

## 📞 Support

If you encounter issues:
1. Check backend logs in terminal
2. Check Flutter logs in console
3. Verify API keys in `.env` file
4. Test API endpoints with curl/Postman
5. Check database has data (mongosh)

---

**Current Status: ✅ Backend ready, database seeded, ready for API integration!**
