import 'package:flutter/material.dart';

import '../../../core/constants/app_defaults.dart';
import '../../../core/routes/app_routes.dart';

class WholesalerInventoryPage extends StatelessWidget {
  const WholesalerInventoryPage({super.key});

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
                    'Product Catalog',
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
                  // TODO: Display products catalog
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.inventory_2),
                      title: Text('Bulk Product 1'),
                      subtitle: Text('Available for Retailers\nStock: 1000 units'),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ),
                  const SizedBox(height: AppDefaults.padding),
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.inventory_2),
                      title: Text('Bulk Product 2'),
                      subtitle: Text('Available for Retailers\nStock: 500 units'),
                      trailing: Icon(Icons.chevron_right),
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

