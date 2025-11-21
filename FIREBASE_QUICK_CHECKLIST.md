# Firebase Setup - Quick Checklist ✅

## 🚀 Quick Steps (30 minutes)

### Step 1: Create Firebase Project (5 min)
1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Name: "eGrocery" (or your app name)
4. Disable Google Analytics (simpler)
5. Click "Create project"

### Step 2: Add Android App (5 min)
1. Click Android icon in Firebase Console
2. **Package name**: Open `android/app/build.gradle`
   - Find `applicationId` (e.g., `com.example.grocery`)
   - Copy and paste in Firebase
3. Click "Register app"
4. **Download** `google-services.json`
5. **Move** to: `android/app/google-services.json`

### Step 3: Enable Authentication (2 min)
1. Firebase Console → **Authentication** → "Get started"
2. Click **Sign-in method** tab
3. Enable **Google**:
   - Toggle ON
   - Select support email
   - Save
4. Enable **Phone**:
   - Toggle ON
   - Save

### Step 4: Get SHA-1 for Google Sign-In (3 min)
```bash
cd android
gradlew signingReport
```
- Copy the SHA1 (looks like `A1:B2:C3:...`)
- Firebase Console → Settings → Your Android app
- Click "Add fingerprint"
- Paste SHA1 → Save

### Step 5: Get Service Account for Backend (3 min)
1. Firebase Console → Settings → **Service accounts**
2. Click "Generate new private key"
3. Download JSON file
4. Open it and copy these values to `backend/nodejs/.env`:

```bash
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
```

### Step 6: Update Flutter Dependencies (2 min)
Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  google_sign_in: ^6.1.6
```

Run:
```bash
flutter pub get
```

### Step 7: Configure Android (3 min)

**File 1: `android/build.gradle`**
Add inside `buildscript { dependencies {`:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

**File 2: `android/app/build.gradle`**
Add at the very bottom:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Step 8: Initialize Firebase in Flutter (2 min)
Update `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Add this line
  runApp(const MyApp());
}
```

### Step 9: Install Backend Dependencies (2 min)
```bash
cd backend/nodejs
npm install firebase-admin
```

### Step 10: Test Everything (3 min)
```bash
# Test Flutter app
flutter run

# Should see in logs:
# ✅ Successfully initialized Firebase

# Test backend
curl http://localhost:3000/health
```

## 📋 Files Checklist

### Files You Need to Download
- [ ] `google-services.json` (from Firebase Console)
- [ ] Service account JSON (from Firebase Console)

### Files You Need to Create/Update
- [ ] `android/app/google-services.json` (place downloaded file here)
- [ ] `backend/nodejs/.env` (add Firebase credentials)
- [ ] `android/build.gradle` (add google-services plugin)
- [ ] `android/app/build.gradle` (apply google-services plugin)
- [ ] `pubspec.yaml` (add Firebase dependencies)
- [ ] `lib/main.dart` (initialize Firebase)

### Files to Add to .gitignore
```
google-services.json
GoogleService-Info.plist
firebase-service-account.json
.env
```

## 🧪 Quick Tests

### Test 1: Firebase Initialized
Run app and check logs for:
```
✅ Successfully initialized Firebase
```

### Test 2: Google Sign-In
Add test button in your app:
```dart
ElevatedButton(
  onPressed: () async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final account = await googleSignIn.signIn();
    print('Signed in: ${account?.email}');
  },
  child: Text('Test Google Sign-In'),
)
```

### Test 3: Phone OTP
Add test phone number in Firebase Console:
- Phone: `+1234567890`
- Code: `123456`

Then test in your app - it will work without sending real SMS!

## 🎯 What You Get

### Google Sign-In
- ✅ Users can sign in with Google account
- ✅ No password needed
- ✅ Automatic profile info (name, email, photo)
- ✅ Works on Android & iOS

### Phone OTP
- ✅ Send OTP via SMS
- ✅ Verify phone numbers
- ✅ 10,000 free verifications/month
- ✅ Test mode for development (no real SMS)

## 💰 Cost

**Everything is FREE for development:**
- Google Sign-In: Unlimited (free forever)
- Phone OTP: 10,000/month free
- Authentication: Unlimited users (free)

## 🐛 Common Issues

### Issue 1: "google-services.json not found"
**Solution**: Make sure file is at `android/app/google-services.json`

### Issue 2: Google Sign-In fails
**Solution**: 
1. Check SHA-1 is added to Firebase
2. Run `flutter clean`
3. Rebuild app

### Issue 3: Phone OTP not sending
**Solution**: 
1. Check Phone provider is enabled in Firebase
2. Use test phone numbers for development
3. Format: `+[country code][number]` (e.g., `+1234567890`)

### Issue 4: Firebase not initializing
**Solution**:
1. Check `google-services.json` exists
2. Verify `apply plugin: 'com.google.gms.google-services'` is at bottom of `android/app/build.gradle`
3. Run `flutter clean`

## 📱 Test Phone Numbers (Development)

Add these in Firebase Console for testing without real SMS:

| Phone Number | OTP Code |
|--------------|----------|
| +1234567890 | 123456 |
| +9876543210 | 654321 |

## ✅ Success Indicators

You'll know it's working when:
1. ✅ App runs without Firebase errors
2. ✅ Google Sign-In button shows Google account picker
3. ✅ Phone OTP sends code (or works with test number)
4. ✅ Backend can verify Firebase tokens
5. ✅ Users can sign in and stay signed in

## 🎉 You're Done!

After completing these steps:
- Google Sign-In will work in your app
- Phone OTP will work for verification
- Backend can verify Firebase authentication
- Everything is free for development

**Next**: Implement the UI for Google Sign-In and Phone OTP in your Flutter app!

---

**Need detailed instructions?** Check `FIREBASE_SETUP_GUIDE.md`

**Need help?** 
- Firebase Console: https://console.firebase.google.com/
- Firebase Docs: https://firebase.google.com/docs
