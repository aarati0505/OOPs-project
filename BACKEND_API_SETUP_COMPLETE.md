# Backend API Setup - Complete ✅

## What Was Done

### 1. Environment Variables (.env file created)
Created `backend/nodejs/.env` with all necessary configuration:

- **Server**: Port 3000, Development mode
- **Database**: MongoDB connected at `mongodb://localhost:27017/ecommerce_db`
- **JWT Secrets**: Secure random keys generated for authentication
  - JWT_SECRET: `d49f405eab13e6c76def70ac6d71b11ee3d67087eeae877590858209c745d821`
  - JWT_REFRESH_SECRET: `2514c6924d15c217abd9d93a47be8f95b366ec304c6c0b0a54abe03e093f1838`
- **JWT Expiry**: 7 days for access tokens, 30 days for refresh tokens
- **OTP**: 10 minutes expiry
- **CORS**: Allows all origins in development

### 2. Backend Server Started
✅ Backend server is running successfully on **http://localhost:3000**

**Available API Endpoints:**
- Health Check: `http://localhost:3000/health`
- API Base: `http://localhost:3000/v1`

**Available Routes:**
- `/v1/auth` - Authentication (login, signup, OTP verification)
- `/v1/users` - User management
- `/v1/products` - Product catalog
- `/v1/orders` - Order management
- `/v1/cart` - Shopping cart
- `/v1/inventory` - Inventory management
- `/v1/categories` - Categories
- `/v1/reviews` - Product reviews
- `/v1/location` - Location services
- `/v1/notifications` - Notifications
- `/v1/retailers` - Retailer operations
- `/v1/wholesalers` - Wholesaler operations

### 3. Flutter App Configuration Updated
✅ Updated `lib/core/constants/app_constants.dart`:
- Changed API base URL from `https://api.yourdomain.com/v1` to `http://localhost:3000/v1`

## Current Status

### Backend Server
- **Status**: ✅ Running
- **Port**: 3000
- **Database**: ✅ Connected to MongoDB
- **Process ID**: 3

### Frontend App
- **API Configuration**: ✅ Updated to use local backend
- **Navigation Fix**: ✅ Role-based navigation implemented
- **OTP Testing**: ✅ Test mode with role selector available

## How to Use

### Backend Server Management

**Check if server is running:**
```bash
# Check the process output
# Process ID: 3
```

**Stop the server:**
```bash
# Use Kiro's process management or:
taskkill /F /PID <process_id>
```

**Restart the server:**
```bash
cd backend/nodejs
npm start
```

### Testing the API

**1. Health Check:**
```bash
curl http://localhost:3000/health
```

**2. Test Signup (with role):**
```bash
curl -X POST http://localhost:3000/v1/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Retailer",
    "email": "retailer@test.com",
    "phoneNumber": "1234567890",
    "password": "password123",
    "role": "retailer",
    "businessName": "Test Store",
    "businessAddress": "123 Main St"
  }'
```

**3. Test OTP Verification:**
```bash
curl -X POST http://localhost:3000/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumber": "1234567890",
    "otp": "1234",
    "role": "retailer",
    "name": "Test Retailer",
    "email": "retailer@test.com",
    "password": "password123",
    "businessName": "Test Store",
    "businessAddress": "123 Main St"
  }'
```

**4. Test Login:**
```bash
curl -X POST http://localhost:3000/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "retailer@test.com",
    "password": "password123"
  }'
```

## Flutter App Testing

### Option 1: Use API (Recommended)
1. Make sure backend server is running
2. Run the Flutter app
3. Go through signup flow
4. Select "Retailer" or "Wholesaler" role
5. Fill in business information
6. Enter any 4-digit OTP
7. Should route to appropriate dashboard

### Option 2: Local Testing Mode
1. Navigate directly to OTP page
2. Use the role selector dropdown
3. Select desired role
4. Enter any 4-digit OTP
5. Should route to appropriate dashboard

## Troubleshooting

### Backend Issues

**Port already in use:**
```bash
# Find process using port 3000
netstat -ano | findstr :3000

# Kill the process
taskkill /F /PID <process_id>

# Restart server
cd backend/nodejs
npm start
```

**MongoDB connection failed:**
- Make sure MongoDB is running
- Check MONGODB_URI in `.env` file
- Default: `mongodb://localhost:27017/ecommerce_db`

**Environment variables not loaded:**
- Make sure `.env` file exists in `backend/nodejs/`
- Restart the server after changing `.env`

### Frontend Issues

**API connection failed:**
- Check if backend server is running
- Verify API base URL in `lib/core/constants/app_constants.dart`
- For Android emulator, use `http://10.0.2.2:3000/v1` instead of `localhost`
- For iOS simulator, `localhost` should work

**Role navigation not working:**
- Check debug logs in console
- Verify signup data is being passed correctly
- Use the test mode role selector if needed

## Next Steps

### To Use API Instead of Local Storage

Update `lib/views/auth/number_verification_page.dart` to use the API:

```dart
// Instead of LocalAuthService.saveLoginState()
// Use AuthApiService.verifyOtp()

final response = await AuthApiService.verifyOtp(
  phoneNumber: _signupData?['phoneNumber'] ?? '',
  otp: otp,
  role: role.name,
  name: _signupData?['name'],
  email: _signupData?['email'],
  password: _signupData?['password'],
  businessName: _signupData?['businessName'],
  businessAddress: _signupData?['businessAddress'],
);
```

### Add Google Maps API Key (Optional)

If you need location services:
1. Get API key from Google Cloud Console
2. Add to `backend/nodejs/.env`:
   ```
   GOOGLE_MAPS_API_KEY=your-api-key-here
   ```

## Files Modified

1. ✅ `backend/nodejs/.env` - Created with all API keys
2. ✅ `lib/core/constants/app_constants.dart` - Updated API base URL
3. ✅ `lib/views/auth/number_verification_page.dart` - Added role selector for testing
4. ✅ `lib/views/auth/dialogs/verified_dialogs.dart` - Fixed navigation stack
5. ✅ `lib/core/services/local_auth_service.dart` - Added business info support

---

**Status: ✅ Backend API is running and ready to use!**

The application can now work with both:
- Local storage (current implementation - for testing)
- Backend API (ready to integrate)
