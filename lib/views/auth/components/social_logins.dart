import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/local_auth_service.dart';

class SocialLogins extends StatelessWidget {
  const SocialLogins({
    super.key,
  });

  Future<void> _signInWithGoogle(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      final authService = AuthService();
      final user = await authService.signInWithGoogle();
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      if (user != null && context.mounted) {
        // Save user to local storage
        await LocalAuthService.saveLoginState(
          userId: user.id,
          name: user.name,
          email: user.email,
          phoneNumber: user.phoneNumber,
          role: user.role,
        );
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Welcome, ${user.name}!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate based on user role
        Navigator.pushReplacementNamed(context, AppRoutes.entryPoint);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to sign in with Google'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.pop(context);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _signInWithGoogle(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.padding * 2,
                  vertical: AppDefaults.padding,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppIcons.googleIconRounded,
                    width: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Google',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppDefaults.margin),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // TODO: Implement Facebook login
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Facebook login coming soon')),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDefaults.padding * 2,
                  vertical: AppDefaults.padding,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.facebook, color: Colors.blue, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Facebook',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
