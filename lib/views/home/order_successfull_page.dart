import 'package:flutter/material.dart';

import '../../core/components/network_image.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/ui_util.dart';
import '../cart/dialogs/delivered_successfull.dart';

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
      body: Column(
        children: [
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: const AspectRatio(
                aspectRatio: 1 / 1,
                child: NetworkImageWithLoader(
                  'https://i.imgur.com/Fj9gVGy.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Column(
              children: [
                Text(
                  'Order Placed Successfully!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Order Details Card
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Order ID:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            orderId,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (couponCode != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Coupon Applied:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              couponCode,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (discount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Discount:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              '- ₹${discount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDefaults.padding),
                  child: Text(
                    'Thanks for your order! Your order has been placed successfully and saved to our database.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.entryPoint,
                          (route) => false,
                        );
                      },
                      child: const Text('Continue Shopping'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDefaults.padding,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Show order saved message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Order $orderId saved in MongoDB'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text('View Order Details'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
