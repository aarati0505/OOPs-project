import 'package:flutter/material.dart';

import '../../../core/constants/app_defaults.dart';
import '../../../core/routes/app_routes.dart';

class RetailerInventoryPage extends StatelessWidget {
  const RetailerInventoryPage({super.key});

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
                    'My Inventory',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to add product page
                      Navigator.pushNamed(context, AppRoutes.newItems);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDefaults.padding),
                children: [
                  // TODO: Display products list
                  // This would typically fetch from a service/database
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.inventory_2),
                      title: Text('Product Name'),
                      subtitle: Text('Stock: 50 | Price: \$10.00'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.inventory_2),
                      title: Text('Product Name 2'),
                      subtitle: Text('Stock: 0 | Out of Stock'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  // Empty state message
                  const Center(
                    child: Text('Add products to manage your inventory'),
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

