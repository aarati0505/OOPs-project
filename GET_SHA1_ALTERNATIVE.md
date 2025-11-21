# 🔑 Get SHA-1 Fingerprint - Alternative Methods

## ❌ Why SHA-1 is REQUIRED for Google Sign-In

**Without SHA-1, Google Sign-In will NOT work!**

You'll get errors like:
- "Sign in failed"
- "Error 10: Developer Error"  
- "API not enabled"
- "PlatformException"

The SHA-1 is how Google verifies your app's identity.

## ✅ Method 1: Using Android Studio (EASIEST - 2 minutes)

1. Open your project in **Android Studio**
2. Click **Gradle** tab on the right side
3. Expand: **OOPs-project** → **android** → **app** → **Tasks** → **android**
4. Double-click **signingReport**
5. Look in the **Run** tab at the bottom
6. Find the line with **SHA1:**
   ```
   SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
   ```
7. Copy this value

## ✅ Method 2: Using Command Prompt (Not PowerShell)

1. Open **Command Prompt** (not PowerShell)
2. Navigate to your project:
   ```cmd
   cd C:\Users\Aarati\StudioProjects\OOPs-project\android
   ```
3. Run:
   ```cmd
   gradlew signingReport
   ```
4. Look for **SHA1** in the output

## ✅ Method 3: Using keytool Directly

1. Find your Java installation:
   - Usually at: `C:\Program Files\Android\Android Studio\jbr\bin\`
   - Or: `C:\Program Files\Java\jdk-XX\bin\`

2. Open Command Prompt and run:
   ```cmd
   "C:\Program Files\Android\Android Studio\jbr\bin\keytool" -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```

3. Look for **SHA1** in the output

## ✅ Method 4: Get from Firebase Console (If you've built before)

If you've already built and run your app on a device:

1. Go to: https://console.firebase.google.com/project/oops-project-a2998/settings/general
2. Scroll to **"Your apps"**
3. Click on your Android app
4. Firebase might show **"Get SHA certificate fingerprints"**
5. Click it and Firebase will try to detect your SHA-1

## ✅ Method 5: Use Default Debug SHA-1 (TEMPORARY - For Testing Only)

For the **debug keystore**, the SHA-1 is usually the same on all machines.

**Common Debug SHA-1:**
```
SHA1: 94:87:30:13:C0:8F:42:B4:27:A4:88:49:C5:3F:F3:D4:7F:9E:72:0F
```

**Try this temporarily:**
1. Add this SHA-1 to Firebase Console
2. Test if Google Sign-In works
3. If it works, great! If not, you need your actual SHA-1

## 🎯 Recommended: Use Android Studio

**This is the EASIEST and most reliable method:**

1. Open project in Android Studio
2. Gradle → app → Tasks → android → signingReport
3. Copy SHA-1
4. Add to Firebase Console

## 📝 After Getting SHA-1

1. Go to: https://console.firebase.google.com/project/oops-project-a2998/settings/general
2. Scroll to **"Your apps"** → Find your Android app
3. Click **"Add fingerprint"**
4. Paste your SHA-1
5. Click **"Save"**

## ⚠️ Important Notes

### Debug vs Release SHA-1
- **Debug SHA-1**: For development/testing (what you need now)
- **Release SHA-1**: For production (needed when you publish to Play Store)

### Multiple SHA-1s
You can add multiple SHA-1 fingerprints to Firebase:
- Debug SHA-1 (for testing)
- Release SHA-1 (for production)
- Different machines (if you develop on multiple computers)

## 🧪 Test After Adding SHA-1

1. Make sure SHA-1 is added to Firebase Console
2. Rebuild your app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```
3. Try Google Sign-In
4. Should work! ✅

## 💡 Quick Fix for Your Current Issue

Since you're having Gradle issues, the **easiest solution** is:

1. **Open Android Studio**
2. **Open your project**
3. **Use Gradle panel** to run signingReport
4. **Copy SHA-1**
5. **Add to Firebase Console**

This avoids all command-line issues!

---

**Bottom Line: You MUST add SHA-1 for Google Sign-In to work. Use Android Studio - it's the easiest way! 🚀**
