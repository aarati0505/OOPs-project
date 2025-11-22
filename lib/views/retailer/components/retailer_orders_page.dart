import 'package:flutter/material.dart';

import '../../../core/constants/app_defaults.dart';
import '../../../core/routes/app_routes.dart';

class RetailerOrdersPage extends StatelessWidget {
  const RetailerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Orders',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  // Filter or status tabs can be added here
                ],
              ),
            ),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Customer Orders'),
                        Tab(text: 'Wholesaler Orders'),
                        Tab(text: 'History'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Customer Orders Tab
                          ListView(
                            padding: const EdgeInsets.all(AppDefaults.padding),
                            children: [
                              Card(
                                child: ListTile(
                                  leading: const Icon(Icons.shopping_bag),
                                  title: const Text('Order #12345'),
                                  subtitle: const Text('Customer: John Doe\nAmount: ₹150.00'),
                                  trailing: const Chip(
                                    label: Text('Pending'),
                                    backgroundColor: Colors.orange,
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(context, AppRoutes.orderDetails);
                                  },
                                ),
                              ),
                            ],
                          ),
                          // Wholesaler Orders Tab
                          ListView(
                            padding: const EdgeInsets.all(AppDefaults.padding),
                            children: [
                              Card(
                                child: ListTile(
                                  leading: const Icon(Icons.store),
                                  title: const Text('Order from Wholesaler'),
                                  subtitle: const Text('Wholesaler: ABC Corp\nAmount: ₹500.00'),
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
                          // History Tab
                          ListView(
                            padding: const EdgeInsets.all(AppDefaults.padding),
                            children: [
                              Card(
                                child: ListTile(
                                  leading: const Icon(Icons.check_circle),
                                  title: const Text('Completed Orders'),
                                  subtitle: const Text('View order history'),
                                  trailing: const Icon(Icons.chevron_right),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

