import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import 'components/wholesaler_inventory_page.dart';
import 'components/wholesaler_orders_page.dart';

/// Wholesaler Dashboard - Entry point for wholesalers
class WholesalerDashboardPage extends StatefulWidget {
  const WholesalerDashboardPage({super.key});

  @override
  State<WholesalerDashboardPage> createState() => _WholesalerDashboardPageState();
}

class _WholesalerDashboardPageState extends State<WholesalerDashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const WholesalerInventoryPage(),
    const WholesalerOrdersPage(),
  ];

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wholesaler Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Retailer Orders',
          ),
        ],
      ),
    );
  }
}

