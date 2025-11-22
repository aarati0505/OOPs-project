import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/api/services/auth_api_service.dart';
import '../../../core/constants/constants.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/models/user_model.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/local_auth_service.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/utils/validators.dart';
import 'login_button.dart';

class LoginPageForm extends StatefulWidget {
  const LoginPageForm({
    super.key,
  });

  @override
  State<LoginPageForm> createState() => _LoginPageFormState();
}

class _LoginPageFormState extends State<LoginPageForm> {
  final _key = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isPasswordShown = false;
  bool _isLoading = false;
  UserRole? _selectedRole; // For testing/demo mode
  bool _useTestMode = false; // Toggle for test mode

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  onPassShowClicked() {
    isPasswordShown = !isPasswordShown;
    setState(() {});
  }

  Future<void> onLogin() async {
    final bool isFormOkay = _key.currentState?.validate() ?? false;
    if (!isFormOkay) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final emailOrPhone = _phoneController.text.trim();
      final password = _passwordController.text;

      UserModel? user;

      // Try API login first (backend authentication)
      try {
        final apiResponse = await AuthApiService.login(
          emailOrPhone: emailOrPhone,
          password: password,
        );

        if (apiResponse.success && apiResponse.data != null) {
          // Save user data from API response (includes correct role)
          user = apiResponse.data!.user;
          
          // Save to local storage for offline access
          await LocalAuthService.saveLoginState(
            userId: user.id,
            name: user.name,
            email: user.email,
            phoneNumber: user.phoneNumber,
            role: user.role, // Use the actual role from backend
          );

          // TODO: Store access token securely (use secure storage)
          // For now, we'll rely on local auth for session management
        }
      } catch (apiError) {
        // API login failed, try Firebase as fallback
        final authService = AuthService();
        if (authService.isFirebaseInitialized) {
          try {
            user = await authService.signInWithEmailPassword(
              emailOrPhone.contains('@') ? emailOrPhone : '$emailOrPhone@demo.com',
              password,
            );
          } catch (firebaseError) {
            // Firebase also failed
          }
        }

        // If both API and Firebase failed, use local auth as last resort (demo mode)
        if (user == null) {
          // This is a fallback for demo/testing - in production, this shouldn't happen
          final demoRole = _useTestMode && _selectedRole != null 
              ? _selectedRole! 
              : UserRole.customer;
          
          await LocalAuthService.saveLoginState(
            userId: 'demo_${DateTime.now().millisecondsSinceEpoch}',
            name: 'Demo User',
            email: emailOrPhone.contains('@') ? emailOrPhone : '$emailOrPhone@demo.com',
            phoneNumber: emailOrPhone.contains('@') ? '' : emailOrPhone,
            role: demoRole, // Use selected role in test mode
          );
          user = await authService.getCurrentUser();
        }
      }
      
      // Override role if test mode is enabled
      if (_useTestMode && _selectedRole != null && user != null) {
        await LocalAuthService.saveLoginState(
          userId: user.id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          role: _selectedRole!, // Override with selected role
        );
      }

      if (mounted) {
        if (user != null) {
          // Navigate to entry point which will route based on user role
          Navigator.pushReplacementNamed(context, AppRoutes.entryPoint);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.defaultTheme.copyWith(
        inputDecorationTheme: AppTheme.secondaryInputDecorationTheme,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Test Mode Toggle
              Row(
                children: [
                  Checkbox(
                    value: _useTestMode,
                    onChanged: (value) {
                      setState(() {
                        _useTestMode = value ?? false;
                        if (!_useTestMode) {
                          _selectedRole = null;
                        }
                      });
                    },
                  ),
                  const Text('Test Mode (Override Role)'),
                ],
              ),
              
              // Role Dropdown (only visible in test mode)
              if (_useTestMode) ...[
                const SizedBox(height: 8),
                const Text("Select Role (Test Mode)"),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    hintText: 'Choose a role',
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: _useTestMode
                      ? (value) => value == null ? 'Please select a role' : null
                      : null,
                ),
                const SizedBox(height: AppDefaults.padding),
              ],
              
              // Email or Phone Field
              const Text("Email or Phone Number"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email or phone is required';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppDefaults.padding),

              // Password Field
              const Text("Password"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                validator: Validators.password.call,
                onFieldSubmitted: (v) => onLogin(),
                textInputAction: TextInputAction.done,
                obscureText: !isPasswordShown,
                decoration: InputDecoration(
                  suffixIcon: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: onPassShowClicked,
                      icon: SvgPicture.asset(
                        AppIcons.eye,
                        width: 24,
                      ),
                    ),
                  ),
                ),
              ),

              // Forget Password labelLarge
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.forgotPassword);
                  },
                  child: const Text('Forget Password?'),
                ),
              ),

              // Login labelLarge
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : LoginButton(onPressed: onLogin),
            ],
          ),
        ),
      ),
    );
  }
}
