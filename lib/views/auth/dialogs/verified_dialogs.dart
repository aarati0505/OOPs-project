import 'package:flutter/material.dart';

import '../../../core/components/network_image.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/routes/app_routes.dart';

class VerifiedDialog extends StatelessWidget {
  final UserRole? userRole;
  
  const VerifiedDialog({super.key, this.userRole});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppDefaults.borderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDefaults.padding * 3,
          horizontal: AppDefaults.padding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.35,
              child: const AspectRatio(
                aspectRatio: 1 / 1,
                child: NetworkImageWithLoader(
                  AppImages.verified,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: AppDefaults.padding),
            Text(
              'Verified!',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDefaults.padding),
            const Text(
              'Hurrah!!  You have successfully\nverified the account.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDefaults.padding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Use pushNamedAndRemoveUntil to clear the navigation stack
                  // This ensures the user can't go back to OTP/signup screens
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.entryPoint,
                    (route) => false,
                  );
                },
                child: const Text('Browse Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
