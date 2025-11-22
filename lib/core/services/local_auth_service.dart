import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../enums/user_role.dart';

class LocalAuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _userRoleKey = 'user_role';
  static const String _businessNameKey = 'business_name';
  static const String _businessAddressKey = 'business_address';

  // Check if user is logged in locally
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Save login state locally
  static Future<void> saveLoginState({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required UserRole role,
    String? businessName,
    String? businessAddress,
  }) async {
    print('🔐 LocalAuthService.saveLoginState called');
    print('   User ID: $userId');
    print('   Name: $name');
    print('   Email: $email');
    print('   Role: ${role.name}');
    print('   Business Name: $businessName');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userPhoneKey, phoneNumber);
    await prefs.setString(_userRoleKey, role.name);
    
    // Save business information for retailers and wholesalers
    if (businessName != null) {
      await prefs.setString(_businessNameKey, businessName);
    }
    if (businessAddress != null) {
      await prefs.setString(_businessAddressKey, businessAddress);
    }
    
    print('✅ LocalAuthService.saveLoginState completed');
  }

  // Get local user
  static Future<UserModel?> getLocalUser() async {
    print('🔍 LocalAuthService.getLocalUser called');
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    
    print('   Is logged in: $isLoggedIn');
    
    if (!isLoggedIn) {
      print('   ❌ User not logged in');
      return null;
    }

    final userId = prefs.getString(_userIdKey);
    final name = prefs.getString(_userNameKey);
    final email = prefs.getString(_userEmailKey);
    final phoneNumber = prefs.getString(_userPhoneKey);
    final roleString = prefs.getString(_userRoleKey);

    print('   User ID: $userId');
    print('   Name: $name');
    print('   Email: $email');
    print('   Role string: $roleString');

    if (userId == null || name == null || email == null || phoneNumber == null || roleString == null) {
      print('   ❌ Missing required fields');
      return null;
    }

    final role = UserRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => UserRole.customer,
    );

    print('   ✅ Parsed role: ${role.name}');

    // Get business information if available
    final businessName = prefs.getString(_businessNameKey);
    final businessAddress = prefs.getString(_businessAddressKey);

    print('   Business Name: $businessName');
    print('   Business Address: $businessAddress');

    return UserModel(
      id: userId,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
      businessName: businessName,
      businessAddress: businessAddress,
      isEmailVerified: false,
      isPhoneVerified: false,
      createdAt: DateTime.now(),
    );
  }

  // Clear login state
  static Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_businessNameKey);
    await prefs.remove(_businessAddressKey);
  }
}

