import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';

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

  void _onSignUpPressed(BuildContext context) {
    // Validate form
    if (formKey.currentState?.validate() ?? false) {
      if (selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an account type')),
        );
        return;
      }

      print('=== DEBUG SIGNUP ===');
      print('Selected role: ${selectedRole?.name}');
      print('Business name: ${businessNameController.text}');
      print('=== END DEBUG ===');

      // TODO: Store registration data temporarily (could use SharedPreferences or Provider)
      // For now, navigate to OTP verification with phone number
      Navigator.pushNamed(
        context,
        AppRoutes.numberVerification,
        arguments: {
          'phoneNumber': phoneController.text,
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
        },
      );
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
