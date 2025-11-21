# 🔑 Get Firebase Credentials for Project: oops-project-a2998

## ✅ What's Already Done
- Firebase Project ID added to backend: `oops-project-a2998`

## 🎯 What You Need to Get Now

### Step 1: Download google-services.json (REQUIRED - 2 minutes)

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: **oops-project-a2998**
3. Click the **⚙️ Settings** icon → **Project settings**
4. Scroll down to **"Your apps"** section
5. If you see your Android app:
   - Click on it
   - Click **"Download google-services.json"**
6. If you DON'T see an Android app:
   - Click **"Add app"** → Select **Android** icon
   - **Android package name**: `com.example.grocery`
   - **App nickname**: "eGrocery Android"
   - Click **"Register app"**
   - Click **"Download google-services.json"**

7. **IMPORTANT**: Move the downloaded file to:
   ```
   android/app/google-services.json
   ```

### Step 2: Get Service Account Credentials (OPTIONAL - for backend - 3 minutes)

Only needed if you want backend to use Firebase Admin SDK.

1. Still in Firebase Console → **⚙️ Settings** → **Project settings**
2. Click **"Service accounts"** tab
3. Click **"Generate new private key"**
4. Click **"Generate key"** (downloads a JSON file)
5. Open the downloaded JSON file
6. Copy these three values:

```json
{
  "project_id": "oops-project-a2998",  ← Already added ✅
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQE...",  ← Copy this
  "client_email": "firebase-adminsdk-xxxxx@oops-project-a2998.iam.gserviceaccount.com"  ← Copy this
}
```

7. Update `backend/nodejs/.env`:

```bash
FIREBASE_PROJECT_ID=oops-project-a2998  # Already set ✅
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nPASTE_YOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@oops-project-a2998.iam.gserviceaccount.com
```

**IMPORTANT**: 
- Keep the quotes around `FIREBASE_PRIVATE_KEY`
- Keep all the `\n` characters in the private key
- The private key is one long line with `\n` representing newlines

### Step 3: Enable Authentication Methods (2 minutes)

1. Firebase Console → **Authentication** → Click **"Get started"** (if first time)
2. Click **"Sign-in method"** tab
3. Enable **Google**:
   - Click on "Google"
   - Toggle **Enable** to ON
   - Select your support email
   - Click **"Save"**
4. Enable **Phone**:
   - Click on "Phone"
   - Toggle **Enable** to ON
   - Click **"Save"**

### Step 4: Add SHA-1 Fingerprint (3 minutes)

For Google Sign-In to work:

1. Open terminal in your project root
2. Run:
   ```bash
   cd android
   gradlew signingReport
   ```
3. Look for output like:
   ```
   Variant: debug
   Config: debug
   SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
   ```
4. Copy the SHA1 value
5. Firebase Console → **⚙️ Settings** → **Project settings**
6. Scroll to **"Your apps"** → Find your Android app
7. Click **"Add fingerprint"**
8. Paste the SHA1
9. Click **"Save"**

### Step 5: Add Test Phone Number (Optional - 1 minute)

For testing without real SMS:

1. Firebase Console → **Authentication** → **Sign-in method**
2. Scroll to **"Phone numbers for testing"**
3. Click **"Add phone number"**
4. Phone: `+1234567890`
5. Code: `123456`
6. Click **"Add"**

Now you can test with this number without sending real SMS!

## 🧪 Test Your Setup

### After Adding google-services.json:

```bash
flutter clean
flutter pub get
flutter run
```

**Expected output:**
```
✅ Firebase initialized successfully
```

### After Adding Backend Credentials:

Restart backend:
```bash
cd backend/nodejs
npm start
```

**Expected output:**
```
✅ Firebase Admin SDK initialized
```

## 📁 File Locations

### Flutter App
```
android/app/google-services.json  ← Place downloaded file here
```

### Backend
```
backend/nodejs/.env  ← Update with Firebase credentials
```

## ✅ Checklist

- [ ] Downloaded google-services.json
- [ ] Placed file at `android/app/google-services.json`
- [ ] Enabled Google Sign-In in Firebase Console
- [ ] Enabled Phone Authentication in Firebase Console
- [ ] Got SHA-1 fingerprint
- [ ] Added SHA-1 to Firebase Console
- [ ] (Optional) Downloaded service account JSON
- [ ] (Optional) Updated `.env` with FIREBASE_PRIVATE_KEY
- [ ] (Optional) Updated `.env` with FIREBASE_CLIENT_EMAIL
- [ ] (Optional) Added test phone number
- [ ] Ran `flutter clean && flutter pub get`
- [ ] Tested app

## 🎯 Minimum Required (to run app)

**Must Have:**
- ✅ `android/app/google-services.json`

**Optional (for backend Firebase features):**
- ⚠️ FIREBASE_PRIVATE_KEY in `.env`
- ⚠️ FIREBASE_CLIENT_EMAIL in `.env`

## 💡 Quick Links

- **Firebase Console**: https://console.firebase.google.com/project/oops-project-a2998
- **Project Settings**: https://console.firebase.google.com/project/oops-project-a2998/settings/general
- **Authentication**: https://console.firebase.google.com/project/oops-project-a2998/authentication

---

**Your Firebase Project ID is already configured! Just add the google-services.json file and you're ready to go! 🚀**
