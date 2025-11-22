import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/api/services/auth_api_service.dart';
import '../../../core/constants/constants.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/local_auth_service.dart';

class SignUpButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final UserRole? selectedRole;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController businessNameController;
  final TextEditingController businessAddressController;

  const SignUpButton({
    super.key,
    required this.formKey,
    required this.selectedRole,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.businessNameController,
    required this.businessAddressController,
  });

  String _formatPhoneNumber(String phone) {
    // Remove any spaces, dashes, or parentheses
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // If it doesn't start with +, add +91 (India country code)
    if (!cleaned.startsWith('+')) {
      cleaned = '+91$cleaned';
    }
    
    return cleaned;
  }

  Future<void> _onSignUpPressed(BuildContext context) async {
    // Validate form
    if (formKey.currentState?.validate() ?? false) {
      if (selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an account type')),
        );
        return;
      }

      // Format phone number with country code
      final formattedPhone = _formatPhoneNumber(phoneController.text);

      print('=== DEBUG SIGNUP ===');
      print('Selected role: ${selectedRole?.name}');
      print('Business name: ${businessNameController.text}');
      print('Original phone: ${phoneController.text}');
      print('Formatted phone: $formattedPhone');
      print('=== END DEBUG ===');

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Save user to MongoDB immediately
        print('💾 Saving user to MongoDB...');
        final response = await AuthApiService.signup(
          name: nameController.text,
          email: emailController.text,
          phoneNumber: formattedPhone, // Use formatted phone
          password: passwordController.text,
          role: selectedRole!,
          businessName: businessNameController.text.isNotEmpty
              ? businessNameController.text
              : null,
          businessAddress: businessAddressController.text.isNotEmpty
              ? businessAddressController.text
              : null,
        );

        // Close loading dialog
        if (context.mounted) {
          Navigator.pop(context);
        }

        if (response.success && response.data != null) {
          print('✅ User saved to MongoDB successfully');
          print('📝 User ID: ${response.data!.user.id}');

          // Save to local storage
          print('💾 Saving to local storage...');
          print('Role from API: ${response.data!.user.role.name}');
          await LocalAuthService.saveLoginState(
            userId: response.data!.user.id,
            name: response.data!.user.name,
            email: response.data!.user.email,
            phoneNumber: response.data!.user.phoneNumber,
            role: response.data!.user.role,
            businessName: response.data!.user.businessName,
            businessAddress: response.data!.user.businessAddress,
          );
          print('✅ Saved to local storage with role: ${response.data!.user.role.name}');

          if (context.mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Account created! Please verify your phone number.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );

            // Navigate to OTP verification for phone verification
            Navigator.pushNamed(
              context,
              AppRoutes.numberVerification,
              arguments: {
                'phoneNumber': formattedPhone, // Use formatted phone with +91
                'name': nameController.text,
                'email': emailController.text,
                'password': passwordController.text,
                'role': selectedRole?.name,
                'businessName': businessNameController.text.isNotEmpty 
                    ? businessNameController.text 
                    : null,
                'businessAddress': businessAddressController.text.isNotEmpty 
                    ? businessAddressController.text 
                    : null,
                'alreadySaved': true, // User already saved to MongoDB
              },
            );
          }
        } else {
          throw Exception(response.message ?? 'Signup failed');
        }
      } catch (e) {
        print('❌ Error saving user: $e');
        
        // Close loading dialog if still open
        if (context.mounted) {
          Navigator.pop(context);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Signup failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDefaults.padding * 2),
      child: Row(
        children: [
          Text(
            'Sign Up',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => _onSignUpPressed(context),
            style: ElevatedButton.styleFrom(elevation: 1),
            child: SvgPicture.asset(
              AppIcons.arrowForward,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
