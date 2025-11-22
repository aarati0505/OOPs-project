import 'package:flutter/material.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';

class OrderSuccessfullPage extends StatelessWidget {
  const OrderSuccessfullPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get order details from navigation arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final orderId = args?['orderId'] ?? 'N/A';
    final totalAmount = args?['totalAmount'] ?? 0.0;
    final discount = args?['discount'] ?? 0.0;
    final couponCode = args?['couponCode'];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Success Image
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: const AspectRatio(
                  aspectRatio: 1 / 1,
                  child: NetworkImageWithLoader(
                    'https://i.imgur.com/Fj9gVGy.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            
            // Success Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
              child: Column(
                children: [
                  Text(
                    'Hurrah!! we just delivered your',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.black,
                          ),
                      children: [
                        TextSpan(
                          text: '#$orderId',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: ' order Successfully.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Spacer(),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Column(
                children: [
                  // Rate The Product Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.submitReview);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Rate The Product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Browse Home Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.entryPoint,
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      child: const Text(
                        'Browse Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
