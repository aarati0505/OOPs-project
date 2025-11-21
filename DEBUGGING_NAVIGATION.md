# Debugging Navigation Issues

If you're still experiencing navigation issues after the fix, use this guide to debug.

## Quick Checks

### 1. Verify User Data is Saved

Add this debug code to `number_verification_page.dart` after saving the user:

```dart
// After LocalAuthService.saveLoginState()
print('=== DEBUG: User saved ===');
print('Role: ${role.name}');
print('Name: ${_signupData!['name']}');
print('Business Name: ${_signupData!['businessName']}');

// After verification
final savedUser = await LocalAuthService.getLocalUser();
print('=== DEBUG: User retrieved ===');
print('Saved user role: ${savedUser?.role.name}');
print('Saved user name: ${savedUser?.name}');
print('Saved business name: ${savedUser?.businessName}');
```

### 2. Verify EntryPoint Routing

Add this debug code to `entrypoint_ui.dart` in the `_loadUser()` method:

```dart
Future<void> _loadUser() async {
  final authService = AuthService();
  final user = await authService.getCurrentUser();
  
  print('=== DEBUG: EntryPoint loading user ===');
  print('User found: ${user != null}');
  print('User role: ${user?.role.name}');
  
  if (mounted) {
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
    // ... rest of the code
  }
}
```

### 3. Check Navigation Stack

Add this to the verified dialog button:

```dart
onPressed: () {
  print('=== DEBUG: Navigating to entry point ===');
  Navigator.pushNamedAndRemoveUntil(
    context,
    AppRoutes.entryPoint,
    (route) {
      print('Route: ${route.settings.name}');
      return false; // Remove all routes
    },
  );
},
```

## Common Issues and Solutions

### Issue 1: User is null in EntryPoint

**Symptom:** EntryPoint redirects to login immediately

**Cause:** User data not saved or not retrieved correctly

**Solution:**
1. Check if `LocalAuthService.saveLoginState()` completes without errors
2. Verify SharedPreferences is working (check device storage permissions)
3. Add delay before navigation: `await Future.delayed(Duration(milliseconds: 200));`

### Issue 2: Wrong Dashboard Displayed

**Symptom:** Retailer sees customer home or vice versa

**Cause:** Role not saved correctly or switch statement in EntryPoint not working

**Solution:**
1. Verify role is saved: Check debug logs from Quick Check #1
2. Verify role is retrieved: Check debug logs from Quick Check #2
3. Check the switch statement in `entrypoint_ui.dart` line 50-58

### Issue 3: Can Navigate Back to OTP Screen

**Symptom:** Back button shows OTP or signup screen

**Cause:** Navigation stack not cleared

**Solution:**
1. Verify `pushNamedAndRemoveUntil` is used (not `pushNamed`)
2. Verify the predicate returns `false` to remove all routes
3. Check if there are multiple navigation calls happening

### Issue 4: Business Information Not Displayed

**Symptom:** Business name/address is null in profile

**Cause:** Business info not saved or not retrieved

**Solution:**
1. Verify business info is in signup data: `print(_signupData!['businessName'])`
2. Verify it's passed to saveLoginState
3. Verify LocalAuthService retrieves it in getLocalUser()

## Manual Testing Steps

### Test 1: Fresh Signup as Retailer

1. Clear app data (or uninstall/reinstall)
2. Go through onboarding
3. Click "Sign Up"
4. Select "Retailer" role
5. Fill in all fields including business name and address
6. Click signup arrow button
7. Enter any 4-digit OTP (e.g., 1234)
8. Click "Browse Home"
9. **Expected:** Should see RetailerDashboardPage with "Inventory" tab
10. **Expected:** Back button should NOT show OTP screen

### Test 2: Fresh Signup as Wholesaler

1. Clear app data
2. Follow same steps as Test 1 but select "Wholesaler" role
3. **Expected:** Should see WholesalerDashboardPage with "Inventory" and "Retailer Orders" tabs

### Test 3: Fresh Signup as Customer

1. Clear app data
2. Follow same steps but select "Customer" role
3. **Expected:** Should see customer home page with bottom navigation (Home, Menu, Cart, Save, Profile)

## Checking Logs

### Android Studio / VS Code

1. Open "Run" tab
2. Look for debug prints starting with `=== DEBUG:`
3. Check for any error messages or exceptions

### Command Line

```bash
flutter logs
```

Look for:
- `=== DEBUG:` messages
- Any exceptions related to SharedPreferences
- Navigation errors

## If All Else Fails

### Nuclear Option: Clear All Data

```dart
// Add this button temporarily to your app
ElevatedButton(
  onPressed: () async {
    await LocalAuthService.clearLoginState();
    print('All user data cleared');
  },
  child: Text('Clear All Data'),
)
```

### Check SharedPreferences Directly

```dart
// Add this to debug
final prefs = await SharedPreferences.getInstance();
print('All keys: ${prefs.getKeys()}');
print('Is logged in: ${prefs.getBool('is_logged_in')}');
print('User role: ${prefs.getString('user_role')}');
```

## Contact Points

If the issue persists:

1. Check the console logs for any errors
2. Verify all files were saved correctly
3. Try a hot restart (not just hot reload)
4. Try uninstalling and reinstalling the app
5. Check if there are any conflicting navigation calls in other parts of the code

---

**Remember:** Always do a hot restart after making changes to navigation logic!
