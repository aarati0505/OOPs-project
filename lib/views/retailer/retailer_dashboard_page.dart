import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../home/home_page.dart';
import 'components/retailer_inventory_page.dart';
import 'components/retailer_orders_page.dart';

/// Retailer Dashboard - Entry point for retailers
class RetailerDashboardPage extends StatefulWidget {
  const RetailerDashboardPage({super.key});

  @override
  State<RetailerDashboardPage> createState() => _RetailerDashboardPageState();
}

class _RetailerDashboardPageState extends State<RetailerDashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const RetailerInventoryPage(),
    const RetailerOrdersPage(),
    const HomePage(), // Browse marketplace
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
        title: const Text('Retailer Dashboard'),
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
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Marketplace',
          ),
        ],
      ),
    );
  }
}

