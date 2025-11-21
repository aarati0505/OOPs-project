# 🔥 Firebase Setup Instructions - What You Need to Do

## ✅ What's Already Done

I've updated all the necessary files in your project:

### Flutter App
- ✅ Added Firebase dependencies to `pubspec.yaml`
- ✅ Updated `lib/main.dart` to initialize Firebase
- ✅ Updated `android/settings.gradle.kts` with Google Services plugin
- ✅ Updated `android/app/build.gradle.kts` to apply Google Services
- ✅ Updated `AndroidManifest.xml` with required permissions

### Backend
- ✅ Installed `firebase-admin` package
- ✅ Created `backend/nodejs/services/firebase.service.js`
- ✅ Updated `backend/nodejs/server.js` to initialize Firebase
- ✅ Updated `backend/nodejs/.env` with Firebase placeholders

## 🎯 What YOU Need to Do (30 minutes)

### Step 1: Create Firebase Project (5 min)

1. Go to https://console.firebase.google.com/
2. Click **"Add project"**
3. Project name: **"eGrocery"** (or your app name)
4. Disable Google Analytics (simpler for now)
5. Click **"Create project"**
6. Wait 30-60 seconds
7. Click **"Continue"**

### Step 2: Add Android App to Firebase (5 min)

1. In Firebase Console, click the **Android icon** 🤖
2. **Android package name**: `com.example.grocery`
   - This is in your `android/app/build.gradle.kts` file
3. **App nickname**: "eGrocery Android" (optional)
4. **SHA-1**: Leave empty for now (we'll add it later)
5. Click **"Register app"**

### Step 3: Download google-services.json (2 min)

1. Click **"Download google-services.json"**
2. **IMPORTANT**: Move this file to:
   ```
   android/app/google-services.json
   ```
3. Click **"Next"** → **"Next"** → **"Continue to console"**

### Step 4: Enable Google Sign-In (2 min)

1. In Firebase Console sidebar: **Authentication** → **"Get started"**
2. Click **"Sign-in method"** tab
3. Find **"Google"** in the list
4. Click on it
5. Toggle **"Enable"** to ON
6. **Support email**: Select your email
7. Click **"Save"**

### Step 5: Enable Phone Authentication (2 min)

1. Still in **"Sign-in method"** tab
2. Find **"Phone"** in the list
3. Click on it
4. Toggle **"Enable"** to ON
5. Click **"Save"**

### Step 6: Add Test Phone Numbers (Optional - 2 min)

For testing without real SMS:

1. Scroll down to **"Phone numbers for testing"**
2. Click **"Add phone number"**
3. Phone: `+1234567890`
4. Code: `123456`
5. Click **"Add"**

Now you can test with this number without sending real SMS!

### Step 7: Get SHA-1 for Google Sign-In (3 min)

Open terminal in your project root:

```bash
cd android
gradlew signingReport
```

Look for output like:
```
Variant: debug
Config: debug
Store: C:\Users\...\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:...
SHA1: A1:B2:C3:D4:E5:F6:...  ← COPY THIS
SHA-256: ...
```

Copy the **SHA1** value.

### Step 8: Add SHA-1 to Firebase (2 min)

1. Firebase Console → **⚙️ Settings** (gear icon) → **Project settings**
2. Scroll to **"Your apps"** section
3. Find your Android app
4. Click **"Add fingerprint"**
5. Paste the SHA1
6. Click **"Save"**

### Step 9: Get Service Account for Backend (3 min)

1. Firebase Console → **⚙️ Settings** → **Project settings**
2. Click **"Service accounts"** tab
3. Click **"Generate new private key"**
4. Click **"Generate key"** (downloads a JSON file)
5. **IMPORTANT**: Keep this file secure! Don't commit to Git!

### Step 10: Update Backend .env (4 min)

Open the downloaded JSON file and find these values:

```json
{
  "project_id": "your-project-id",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",
  "client_email": "firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com"
}
```

Update `backend/nodejs/.env`:

```bash
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour\nPrivate\nKey\nHere\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
```

**IMPORTANT**: 
- Keep the quotes around `FIREBASE_PRIVATE_KEY`
- Keep the `\n` characters (they represent newlines)

## 🧪 Test Your Setup

### Test 1: Run Flutter App

```bash
flutter clean
flutter pub get
flutter run
```

Check logs for:
```
✅ Firebase initialized successfully
```

### Test 2: Test Backend

Restart your backend server:
```bash
cd backend/nodejs
npm start
```

Check logs for:
```
✅ Firebase Admin SDK initialized
```

Or if you haven't added credentials yet:
```
⚠️  Firebase credentials not found in .env
   App will use mock authentication for testing
```

### Test 3: Test Google Sign-In (Optional)

Add a test button in your Flutter app:

```dart
import 'package:google_sign_in/google_sign_in.dart';

ElevatedButton(
  onPressed: () async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final account = await googleSignIn.signIn();
    if (account != null) {
      print('✅ Signed in: ${account.email}');
    }
  },
  child: Text('Test Google Sign-In'),
)
```

### Test 4: Test Phone OTP (Optional)

Use the test phone number you added:
- Phone: `+1234567890`
- OTP: `123456`

This will work without sending real SMS!

## 📁 Files You Need

### Must Have
- ✅ `android/app/google-services.json` (from Firebase Console)

### Optional (for backend Firebase features)
- ⚠️ Firebase service account JSON (for backend)
- ⚠️ Update `.env` with Firebase credentials

## 🎉 What Works Now

### Without Firebase Credentials (Current State)
- ✅ App runs normally
- ✅ Mock OTP (any 4 digits work)
- ✅ Local authentication
- ✅ All features work for testing

### With Firebase Credentials (After Setup)
- ✅ Real Google Sign-In
- ✅ Real SMS OTP
- ✅ Firebase authentication
- ✅ Secure token verification
- ✅ Production-ready

## 🐛 Troubleshooting

### "google-services.json not found"
**Solution**: Make sure file is at `android/app/google-services.json`

### "Firebase initialization failed"
**Solution**: 
1. Check `google-services.json` exists
2. Run `flutter clean`
3. Run `flutter pub get`
4. Rebuild app

### Google Sign-In not working
**Solution**:
1. Check SHA-1 is added to Firebase
2. Verify package name matches
3. Run `flutter clean` and rebuild

### Backend Firebase error
**Solution**:
1. Check `.env` has correct Firebase credentials
2. Verify private key has quotes and `\n` characters
3. Restart backend server

## 💡 Pro Tips

1. **Test Mode**: You can test everything without Firebase credentials. The app uses mock authentication.

2. **Test Phone Numbers**: Add test phone numbers in Firebase Console to avoid SMS costs during development.

3. **Security**: Never commit `google-services.json` or Firebase service account JSON to Git!

4. **Free Tier**: Firebase is free for:
   - Google Sign-In: Unlimited
   - Phone OTP: 10,000/month
   - Authentication: Unlimited users

## 📞 Need Help?

- **Firebase Console**: https://console.firebase.google.com/
- **Firebase Docs**: https://firebase.google.com/docs
- **Flutter Firebase**: https://firebase.flutter.dev/

---

## ✅ Quick Checklist

- [ ] Created Firebase project
- [ ] Added Android app to Firebase
- [ ] Downloaded `google-services.json`
- [ ] Placed file in `android/app/google-services.json`
- [ ] Enabled Google Sign-In in Firebase
- [ ] Enabled Phone Authentication in Firebase
- [ ] Got SHA-1 fingerprint
- [ ] Added SHA-1 to Firebase
- [ ] (Optional) Downloaded service account JSON
- [ ] (Optional) Updated backend `.env` with Firebase credentials
- [ ] Ran `flutter clean && flutter pub get`
- [ ] Tested app - Firebase initialized successfully

**You're ready to go! 🚀**
