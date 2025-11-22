import 'package:flutter/material.dart';

import '../../../core/constants/app_defaults.dart';
import '../../../core/routes/app_routes.dart';

class WholesalerOrdersPage extends StatelessWidget {
  const WholesalerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Text(
                'Retailer Orders',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDefaults.padding),
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.store),
                      title: const Text('Order from Retailer XYZ'),
                      subtitle: const Text('Retailer: ABC Store\nAmount: ₹1,200.00\nProducts: 50 items'),
                      trailing: const Chip(
                        label: Text('New'),
                        backgroundColor: Colors.green,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.orderDetails);
                      },
                    ),
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.shopping_cart),
                      title: const Text('Order from Retailer DEF'),
                      subtitle: const Text('Retailer: DEF Store\nAmount: ₹800.00\nProducts: 30 items'),
                      trailing: const Chip(
                        label: Text('Processing'),
                        backgroundColor: Colors.blue,
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.orderDetails);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

