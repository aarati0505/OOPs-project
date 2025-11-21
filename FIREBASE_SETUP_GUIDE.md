# Firebase Setup Guide - Google Sign-In & OTP Verification

## Overview
This guide will help you set up Firebase for:
1. **Google Sign-In** (Social Authentication)
2. **Phone OTP Verification** (SMS Authentication)

## Part 1: Create Firebase Project

### Step 1: Go to Firebase Console
1. Visit: https://console.firebase.google.com/
2. Click **"Add project"** or **"Create a project"**

### Step 2: Create Project
1. **Project name**: Enter your app name (e.g., "eGrocery" or "OOPs-project")
2. Click **Continue**
3. **Google Analytics**: 
   - Toggle OFF if you don't need it (simpler setup)
   - Or keep ON and select/create Analytics account
4. Click **Create project**
5. Wait for project creation (30-60 seconds)
6. Click **Continue**

## Part 2: Add Apps to Firebase

### For Android App

#### Step 1: Register Android App
1. In Firebase Console, click the **Android icon** (robot)
2. **Android package name**: 
   - Open `android/app/build.gradle` in your Flutter project
   - Find `applicationId` (e.g., `com.example.grocery`)
   - Enter this in Firebase
3. **App nickname**: (Optional) e.g., "eGrocery Android"
4. **Debug signing certificate SHA-1**: (Optional for now, needed later for Google Sign-In)
   - Skip for now, we'll add it later
5. Click **Register app**

#### Step 2: Download google-services.json
1. Click **Download google-services.json**
2. Move this file to: `android/app/google-services.json` in your Flutter project
3. Click **Next**

#### Step 3: Add Firebase SDK (Already done if you have dependencies)
1. Firebase will show you code to add
2. Most Flutter projects already have this
3. Click **Next** → **Continue to console**

### For iOS App (If you need iOS support)

#### Step 1: Register iOS App
1. In Firebase Console, click the **iOS icon** (Apple)
2. **iOS bundle ID**: 
   - Open `ios/Runner.xcodeproj` in Xcode
   - Or check `ios/Runner/Info.plist` for bundle identifier
   - Enter this in Firebase (e.g., `com.example.grocery`)
3. **App nickname**: (Optional) e.g., "eGrocery iOS"
4. Click **Register app**

#### Step 2: Download GoogleService-Info.plist
1. Click **Download GoogleService-Info.plist**
2. Move this file to: `ios/Runner/GoogleService-Info.plist`
3. Click **Next** → **Continue to console**

## Part 3: Enable Authentication Methods

### Enable Google Sign-In

#### Step 1: Go to Authentication
1. In Firebase Console sidebar, click **Build** → **Authentication**
2. Click **Get started** (if first time)

#### Step 2: Enable Google Provider
1. Click **Sign-in method** tab
2. Find **Google** in the list
3. Click on **Google**
4. Toggle **Enable** to ON
5. **Project support email**: Select your email from dropdown
6. Click **Save**

✅ **Google Sign-In is now enabled!**

### Enable Phone Authentication (OTP)

#### Step 1: Enable Phone Provider
1. Still in **Authentication** → **Sign-in method** tab
2. Find **Phone** in the list
3. Click on **Phone**
4. Toggle **Enable** to ON
5. Click **Save**

#### Step 2: Configure Phone Authentication Settings
1. Scroll down to **Phone numbers for testing** (optional)
2. You can add test phone numbers for development:
   - Phone number: `+1234567890`
   - Verification code: `123456`
3. This allows testing without sending real SMS

✅ **Phone OTP is now enabled!**

## Part 4: Get Configuration Details

### For Backend (Node.js)

#### Step 1: Create Service Account
1. In Firebase Console, click **⚙️ Settings** (gear icon) → **Project settings**
2. Click **Service accounts** tab
3. Click **Generate new private key**
4. Click **Generate key** (downloads a JSON file)
5. **IMPORTANT**: Keep this file secure! Don't commit to Git!

#### Step 2: Extract Values for .env
Open the downloaded JSON file and find these values:

```json
{
  "project_id": "your-project-id",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",
  "client_email": "firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com"
}
```

Add to `backend/nodejs/.env`:
```bash
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour\nPrivate\nKey\nHere\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
```

**Note**: Keep the quotes around FIREBASE_PRIVATE_KEY and preserve the `\n` characters!

### For Flutter App

#### Step 1: Get Web Client ID (for Google Sign-In)
1. In Firebase Console → **⚙️ Settings** → **Project settings**
2. Scroll down to **Your apps** section
3. Find your **Web app** (if not created, click **Add app** → **Web**)
4. Copy the **Web client ID** (looks like: `123456789-abcdefg.apps.googleusercontent.com`)

#### Step 2: Get Android SHA-1 (for Google Sign-In)
Run this command in your project root:

```bash
# Windows
cd android
gradlew signingReport

# Mac/Linux
cd android
./gradlew signingReport
```

Look for **SHA1** under `Task :app:signingReport` → `Variant: debug`

Copy the SHA1 (looks like: `A1:B2:C3:D4:...`)

#### Step 3: Add SHA-1 to Firebase
1. Firebase Console → **⚙️ Settings** → **Project settings**
2. Scroll to **Your apps** → Select your Android app
3. Click **Add fingerprint**
4. Paste the SHA-1
5. Click **Save**

## Part 5: Update Flutter Dependencies

### pubspec.yaml
Add these dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase Core (Required)
  firebase_core: ^2.24.2
  
  # Firebase Auth (Required)
  firebase_auth: ^4.15.3
  
  # Google Sign-In
  google_sign_in: ^6.1.6
  
  # Phone Auth (already included in firebase_auth)
```

Run:
```bash
flutter pub get
```

## Part 6: Configure Flutter for Firebase

### Android Configuration

#### 1. Update android/build.gradle
```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### 2. Update android/app/build.gradle
At the bottom of the file, add:
```gradle
apply plugin: 'com.google.gms.google-services'
```

#### 3. Update android/app/src/main/AndroidManifest.xml
Add inside `<application>` tag:
```xml
<meta-data
    android:name="com.google.android.gms.version"
    android:value="@integer/google_play_services_version" />
```

### iOS Configuration (if needed)

#### 1. Update ios/Runner/Info.plist
Add before `</dict>`:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

## Part 7: Initialize Firebase in Flutter

### Update lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eGrocery',
      theme: AppTheme.defaultTheme,
      onGenerateRoute: RouteGenerator.onGenerate,
      initialRoute: AppRoutes.onboarding,
    );
  }
}
```

## Part 8: Test Firebase Setup

### Test 1: Check Firebase Initialization
Run your Flutter app and check for errors. You should see in logs:
```
[firebase_core] Successfully initialized Firebase
```

### Test 2: Test Google Sign-In (Simple Test)
Create a test button:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> testGoogleSignIn() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    if (googleUser != null) {
      print('✅ Google Sign-In Success: ${googleUser.email}');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      await FirebaseAuth.instance.signInWithCredential(credential);
      print('✅ Firebase Auth Success');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### Test 3: Test Phone OTP (Simple Test)
```dart
import 'package:firebase_auth/firebase_auth.dart';

Future<void> testPhoneOTP(String phoneNumber) async {
  try {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber, // e.g., '+1234567890'
      verificationCompleted: (PhoneAuthCredential credential) {
        print('✅ Auto-verification completed');
      },
      verificationFailed: (FirebaseAuthException e) {
        print('❌ Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        print('✅ Code sent! Verification ID: $verificationId');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('⏱️ Timeout');
      },
    );
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

## Part 9: Backend Integration

### Install Firebase Admin SDK
```bash
cd backend/nodejs
npm install firebase-admin
```

### Create Firebase Service (backend/nodejs/services/firebase.service.js)
```javascript
const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = {
  projectId: process.env.FIREBASE_PROJECT_ID,
  privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Verify ID Token
async function verifyIdToken(idToken) {
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    return decodedToken;
  } catch (error) {
    throw new Error('Invalid token');
  }
}

// Send OTP via Firebase (optional - Firebase handles this automatically)
async function sendOTP(phoneNumber) {
  // Firebase automatically sends OTP when you call verifyPhoneNumber from client
  // This is just for custom implementation if needed
  return { success: true };
}

module.exports = {
  verifyIdToken,
  sendOTP,
  admin,
};
```

## Part 10: Important Notes

### Free Tier Limits
- **Phone Auth**: 10,000 verifications/month free
- **Google Sign-In**: Unlimited (free)
- **Authentication**: Unlimited users (free)

### Security Rules
1. **Never commit** `google-services.json` or `GoogleService-Info.plist` to public repos
2. **Never commit** Firebase service account JSON to Git
3. Add to `.gitignore`:
   ```
   google-services.json
   GoogleService-Info.plist
   firebase-service-account.json
   ```

### Testing Phone OTP
For development, use test phone numbers in Firebase Console:
1. Firebase Console → Authentication → Sign-in method → Phone
2. Scroll to "Phone numbers for testing"
3. Add: `+1234567890` with code `123456`
4. This won't send real SMS but will work in your app

### Production Checklist
- [ ] Enable App Check (prevents abuse)
- [ ] Set up billing alerts
- [ ] Configure authorized domains
- [ ] Add production SHA-1 fingerprint
- [ ] Test on real devices
- [ ] Monitor usage in Firebase Console

## Troubleshooting

### Google Sign-In Not Working
1. Check SHA-1 is added to Firebase
2. Verify `google-services.json` is in `android/app/`
3. Check package name matches in Firebase and `build.gradle`
4. Run `flutter clean` and rebuild

### Phone OTP Not Sending
1. Check Phone provider is enabled in Firebase
2. Verify phone number format: `+[country code][number]`
3. Check Firebase quota (10k/month free)
4. Use test phone numbers for development

### Firebase Not Initializing
1. Check `google-services.json` exists
2. Verify `apply plugin: 'com.google.gms.google-services'` in `build.gradle`
3. Run `flutter clean`
4. Check Firebase Console for app configuration

## Summary Checklist

### Firebase Console
- [x] Create Firebase project
- [x] Add Android app
- [x] Download `google-services.json`
- [x] Enable Google Sign-In
- [x] Enable Phone Authentication
- [x] Add SHA-1 fingerprint
- [x] Create service account (for backend)

### Flutter App
- [x] Add Firebase dependencies
- [x] Place `google-services.json` in `android/app/`
- [x] Update `build.gradle` files
- [x] Initialize Firebase in `main.dart`
- [x] Test Firebase initialization

### Backend
- [x] Install `firebase-admin`
- [x] Add Firebase credentials to `.env`
- [x] Create Firebase service
- [x] Test token verification

## Next Steps

1. **Implement Google Sign-In** in your login page
2. **Implement Phone OTP** in your signup flow
3. **Test** with real devices
4. **Monitor** usage in Firebase Console
5. **Deploy** to production when ready

---

**Need Help?**
- Firebase Docs: https://firebase.google.com/docs
- Flutter Firebase: https://firebase.flutter.dev/
- Firebase Console: https://console.firebase.google.com/

**Your Firebase is ready! 🎉**
