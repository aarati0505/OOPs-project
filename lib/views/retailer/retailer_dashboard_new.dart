import 'package:flutter/material.dart';
import 'package:grocery/core/constants/app_colors.dart';
import 'package:grocery/core/constants/app_defaults.dart';
import 'package:grocery/core/models/dashboard_model.dart';
import 'package:grocery/core/api/api_client.dart';
import 'package:grocery/core/constants/app_constants.dart';
import 'package:grocery/views/shared/components/kpi_tile.dart';
import 'package:grocery/views/shared/components/status_badge.dart';

/// Enhanced Retailer Dashboard with Analytics and Quick Actions
class RetailerDashboardNew extends StatefulWidget {
  const RetailerDashboardNew({super.key});

  @override
  State<RetailerDashboardNew> createState() => _RetailerDashboardNewState();
}

class _RetailerDashboardNewState extends State<RetailerDashboardNew> {
  bool _isLoading = true;
  DashboardModel? _dashboard;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiClient.get(
        AppConstants.dashboardEndpoint,
        token: 'YOUR_TOKEN_HERE', // Get from auth service
      );

      final json = ApiClient.handleResponse(response);
      setState(() {
        _dashboard = DashboardModel.fromJson(json['data'] as Map<String, dynamic>);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldWithBoxBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Retailer Dashboard'),
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.placeholder,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : _buildDashboardContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(_error ?? 'Failed to load dashboard'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboard,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    final stats = _dashboard!.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDefaults.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Tiles Grid
          _buildKPIGrid(stats),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 24),

          // Low Stock Alerts
          if (_dashboard!.lowStockProducts != null &&
              _dashboard!.lowStockProducts!.isNotEmpty) ...[
            _buildSectionHeader('Low Stock Alerts', Icons.warning_amber_rounded),
            const SizedBox(height: 12),
            _buildLowStockSection(),
            const SizedBox(height: 24),
          ],

          // Recent Customer Orders
          if (_dashboard!.recentCustomerOrders != null &&
              _dashboard!.recentCustomerOrders!.isNotEmpty) ...[
            _buildSectionHeader('Recent Customer Orders', Icons.shopping_cart),
            const SizedBox(height: 12),
            _buildRecentCustomerOrders(),
            const SizedBox(height: 24),
          ],

          // Wholesale Orders
          if (_dashboard!.wholesaleOrders != null &&
              _dashboard!.wholesaleOrders!.isNotEmpty) ...[
            _buildSectionHeader('Wholesale Orders', Icons.local_shipping),
            const SizedBox(height: 12),
            _buildWholesaleOrders(),
          ],
        ],
      ),
    );
  }

  Widget _buildKPIGrid(DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppDefaults.padding,
      crossAxisSpacing: AppDefaults.padding,
      childAspectRatio: 1.3,
      children: [
        KPITile(
          title: 'Total Products',
          value: '${stats.totalProducts ?? 0}',
          icon: Icons.inventory_2_outlined,
          subtitle: '${stats.inStock ?? 0} in stock',
          onTap: () {
            // Navigate to inventory
          },
        ),
        KPITile(
          title: 'Total Revenue',
          value: '₹${(stats.totalRevenue ?? 0).toStringAsFixed(0)}',
          icon: Icons.attach_money,
          color: Colors.green,
          subtitle: '${stats.completedOrders ?? 0} orders',
        ),
        KPITile(
          title: 'Pending Orders',
          value: '${stats.pendingOrders ?? 0}',
          icon: Icons.pending_actions,
          color: Colors.orange,
          onTap: () {
            // Navigate to pending orders
          },
        ),
        KPITile(
          title: 'Low Stock',
          value: '${_dashboard!.lowStockProducts?.length ?? 0}',
          icon: Icons.warning,
          color: Colors.red,
          onTap: () {
            // Navigate to low stock
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_circle_outline,
                label: 'Add Product',
                onTap: () {
                  // Navigate to add product
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.cloud_download_outlined,
                label: 'Import from Wholesaler',
                color: Colors.blue,
                onTap: () {
                  // Navigate to import wholesaler products
                  Navigator.pushNamed(context, '/retailer/import-wholesaler');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.inventory_outlined,
                label: 'Manage Inventory',
                color: Colors.purple,
                onTap: () {
                  // Navigate to inventory
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.local_shipping_outlined,
                label: 'Wholesale Orders',
                color: Colors.indigo,
                onTap: () {
                  // Navigate to wholesale orders
                  Navigator.pushNamed(context, '/retailer/wholesale-orders');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text('View All'),
        ),
      ],
    );
  }

  Widget _buildLowStockSection() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dashboard!.lowStockProducts!.length.clamp(0, 3),
      itemBuilder: (context, index) {
        final product = _dashboard!.lowStockProducts![index];
        return _LowStockProductCard(product: product);
      },
    );
  }

  Widget _buildRecentCustomerOrders() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dashboard!.recentCustomerOrders!.length.clamp(0, 3),
      itemBuilder: (context, index) {
        final order = _dashboard!.recentCustomerOrders![index];
        return _OrderSummaryCard(order: order);
      },
    );
  }

  Widget _buildWholesaleOrders() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dashboard!.wholesaleOrders!.length.clamp(0, 3),
      itemBuilder: (context, index) {
        final order = _dashboard!.wholesaleOrders![index];
        return _OrderSummaryCard(
          order: order,
          showWholesaler: true,
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;

    return Material(
      color: buttonColor.withOpacity(0.1),
      borderRadius: AppDefaults.borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDefaults.borderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: AppDefaults.borderRadius,
            border: Border.all(color: buttonColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: buttonColor, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: buttonColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LowStockProductCard extends StatelessWidget {
  final ProductSummary product;

  const _LowStockProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.gray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
              ? Image.network(product.imageUrl!, fit: BoxFit.cover)
              : const Icon(Icons.inventory),
        ),
        title: Text(product.name),
        subtitle: Text('Stock: ${product.stock ?? 0}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Low',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final OrderSummary order;
  final bool showWholesaler;

  const _OrderSummaryCard({
    required this.order,
    this.showWholesaler = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            showWholesaler ? Icons.warehouse : Icons.shopping_bag,
            color: AppColors.primary,
          ),
        ),
        title: Text('Order #${order.id.substring(order.id.length - 6)}'),
        subtitle: Text(
          showWholesaler
              ? 'From: ${order.wholesalerName ?? "Wholesaler"}'
              : 'Customer: ${order.customerName ?? "Customer"}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${order.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            StatusBadge(status: order.status, isSmall: true),
          ],
        ),
      ),
    );
  }
}

