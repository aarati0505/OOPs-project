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
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userPhoneKey, phoneNumber);
    await prefs.setString(_userRoleKey, role.name);
  }

  // Get local user
  static Future<UserModel?> getLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    
    if (!isLoggedIn) {
      return null;
    }

    final userId = prefs.getString(_userIdKey);
    final name = prefs.getString(_userNameKey);
    final email = prefs.getString(_userEmailKey);
    final phoneNumber = prefs.getString(_userPhoneKey);
    final roleString = prefs.getString(_userRoleKey);

    if (userId == null || name == null || email == null || phoneNumber == null || roleString == null) {
      return null;
    }

    final role = UserRole.values.firstWhere(
      (e) => e.name == roleString,
      orElse: () => UserRole.customer,
    );

    return UserModel(
      id: userId,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      role: role,
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
  }
}

