# Signup Role-Based Navigation Fix

## Problem
After completing signup (signup form → OTP verification → "Browse Home" button), users were always redirected to the customer home page regardless of the role selected during signup (retailer/wholesaler).

## Root Cause
1. **OTP Verification Not Completing Signup**: The OTP verification page was not actually calling the signup API or saving the user with their selected role.
2. **No User Saved**: After OTP verification, no user was saved to local storage, so when navigating to `entryPoint`, there was no user data to check the role.
3. **Missing Signup Data**: The signup data (including role) was passed to OTP verification page but never used to complete the signup.

## Solution

### Backend Changes (`backend/nodejs/controllers/auth.controller.js`)

**Updated `verifyOtp` endpoint** to:
1. Accept full signup data: `password`, `businessName`, `businessAddress` (in addition to existing `role`, `name`, `email`)
2. Create user with correct role and all signup data when user doesn't exist
3. Update existing user's role if provided
4. Return user data with tokens (via `issueAuthTokens`)

**Key Changes:**
- Now accepts `password`, `businessName`, `businessAddress` in request body
- Creates user with proper password hash (not placeholder)
- Uses `ValidationError` for consistent error handling
- Returns user with correct role in response

### Frontend Changes

#### 1. `lib/core/api/services/auth_api_service.dart`
- Updated `verifyOtp` method to accept optional `password`, `businessName`, `businessAddress` parameters
- Sends all signup data to backend during OTP verification

#### 2. `lib/views/auth/number_verification_page.dart`
- **Converted to StatefulWidget** to manage signup data and OTP state
- **Retrieves signup data** from route arguments (passed from signup form)
- **OTP Auto-Verification**: When user completes 4-digit OTP, automatically calls `_handleOtpVerification`
- **Manual Verify Button**: Collects OTP from text fields and verifies
- **Saves User with Role**: After successful OTP verification, saves user to `LocalAuthService` with correct role
- **Shows Verified Dialog**: Displays success dialog with user's role
- **Updated OTPTextFields**: Made stateful with `getOtp()` method to retrieve OTP value

#### 3. `lib/views/auth/dialogs/verified_dialogs.dart`
- Added `userRole` parameter to `VerifiedDialog`
- Dialog now receives and can display role-specific message (future enhancement)

## How It Works Now

### Signup Flow:
1. **User fills signup form** → Selects role (customer/retailer/wholesaler), enters name, email, phone, password, business info
2. **Navigates to OTP verification** → Signup data passed as route arguments
3. **User enters OTP** → When 4 digits complete, automatically verifies
4. **Backend verifies OTP** → Creates/updates user with correct role and all signup data
5. **Frontend saves user** → Saves to `LocalAuthService` with correct role
6. **Shows success dialog** → "Browse Home" button appears
7. **Navigates to EntryPoint** → `entrypoint_ui.dart` checks user role:
   - `UserRole.customer` → `CustomerEntryPointUI` (home page with bottom nav)
   - `UserRole.retailer` → `RetailerDashboardPage`
   - `UserRole.wholesaler` → `WholesalerDashboardPage`

## Testing

To test the fix:

1. **Signup as Retailer:**
   - Fill signup form, select "Retailer" role
   - Enter business name and address
   - Complete OTP verification
   - Click "Browse Home"
   - Should see `RetailerDashboardPage` with inventory management

2. **Signup as Wholesaler:**
   - Fill signup form, select "Wholesaler" role
   - Enter business name and address
   - Complete OTP verification
   - Click "Browse Home"
   - Should see `WholesalerDashboardPage`

3. **Signup as Customer:**
   - Fill signup form, select "Customer" role
   - Complete OTP verification
   - Click "Browse Home"
   - Should see customer home page with bottom navigation

## Files Modified

### Backend
- ✅ `backend/nodejs/controllers/auth.controller.js` - Updated `verifyOtp` to accept full signup data and create user with correct role

### Frontend
- ✅ `lib/core/api/services/auth_api_service.dart` - Updated `verifyOtp` to send signup data
- ✅ `lib/views/auth/number_verification_page.dart` - Complete rewrite to handle OTP verification and signup completion
- ✅ `lib/views/auth/dialogs/verified_dialogs.dart` - Added `userRole` parameter

## Key Improvements

1. **Role Preservation**: User's selected role is now preserved throughout the signup flow
2. **Complete Signup**: Signup is actually completed with all data (password, business info) after OTP verification
3. **Automatic Verification**: OTP auto-verifies when 4 digits are entered
4. **Manual Verification**: Verify button also works by collecting OTP from fields
5. **Error Handling**: Proper error messages for OTP verification failures
6. **User Saved**: User is saved to local storage with correct role before navigation

---

**The signup flow now correctly routes users to their role-specific dashboards!** ✅

