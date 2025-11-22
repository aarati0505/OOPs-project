import 'package:flutter/material.dart';
import 'package:grocery/core/constants/app_colors.dart';
import 'package:grocery/core/constants/app_defaults.dart';
import 'package:grocery/core/models/dashboard_model.dart';
import 'package:grocery/core/api/api_client.dart';
import 'package:grocery/core/constants/app_constants.dart';
import 'package:grocery/views/shared/components/kpi_tile.dart';
import 'package:grocery/views/shared/components/status_badge.dart';

/// Enhanced Wholesaler Dashboard with Analytics and Order Management
class WholesalerDashboardNew extends StatefulWidget {
  const WholesalerDashboardNew({super.key});

  @override
  State<WholesalerDashboardNew> createState() => _WholesalerDashboardNewState();
}

class _WholesalerDashboardNewState extends State<WholesalerDashboardNew> {
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
            const Text('Wholesaler Dashboard'),
            Text(
              'Manage your wholesale business',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to add product
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        backgroundColor: AppColors.primary,
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

          // Recent Wholesale Orders Section
          if (_dashboard!.recentOrders != null &&
              _dashboard!.recentOrders!.isNotEmpty) ...[
            _buildSectionHeader('Recent Wholesale Orders', Icons.local_shipping),
            const SizedBox(height: 12),
            _buildRecentOrders(),
            const SizedBox(height: 24),
          ],

          // Top Selling Products
          if (_dashboard!.topSellingProducts != null &&
              _dashboard!.topSellingProducts!.isNotEmpty) ...[
            _buildSectionHeader('Top Selling Products', Icons.trending_up),
            const SizedBox(height: 12),
            _buildTopSellingProducts(),
            const SizedBox(height: 24),
          ],

          // Retailer Activity
          _buildRetailerActivity(stats),
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
          title: 'Total Retailers',
          value: '${stats.totalRetailers ?? 0}',
          icon: Icons.store,
          color: Colors.blue,
          subtitle: 'Active partners',
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
          title: 'Total Products',
          value: '${stats.totalProducts ?? 0}',
          icon: Icons.inventory_2_outlined,
          subtitle: '${stats.inStock ?? 0} in stock',
          onTap: () {
            // Navigate to inventory
          },
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

  Widget _buildRecentOrders() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _dashboard!.recentOrders!.length.clamp(0, 3),
      itemBuilder: (context, index) {
        final order = _dashboard!.recentOrders![index];
        return _WholesaleOrderCard(order: order);
      },
    );
  }

  Widget _buildTopSellingProducts() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dashboard!.topSellingProducts!.length,
        itemBuilder: (context, index) {
          final product = _dashboard!.topSellingProducts![index];
          return _TopProductCard(product: product);
        },
      ),
    );
  }

  Widget _buildRetailerActivity(DashboardStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Business Insights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InsightRow(
              icon: Icons.inventory_2,
              label: 'Total Inventory Value',
              value: '₹${(stats.totalInventoryValue ?? 0).toStringAsFixed(2)}',
            ),
            const Divider(height: 24),
            _InsightRow(
              icon: Icons.check_circle,
              label: 'Completed Orders',
              value: '${stats.completedOrders ?? 0}',
            ),
            const Divider(height: 24),
            _InsightRow(
              icon: Icons.trending_up,
              label: 'Average Order Value',
              value: stats.totalOrders != null && stats.totalOrders! > 0
                  ? '₹${((stats.totalRevenue ?? 0) / stats.totalOrders!).toStringAsFixed(2)}'
                  : '₹0.00',
            ),
          ],
        ),
      ),
    );
  }
}

class _WholesaleOrderCard extends StatelessWidget {
  final RecentOrder order;

  const _WholesaleOrderCard({required this.order});

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
          child: const Icon(Icons.local_shipping, color: AppColors.primary),
        ),
        title: Text('Order #${order.id.substring(order.id.length - 6)}'),
        subtitle: Text('${order.itemCount} items'),
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
        onTap: () {
          // Navigate to order details
        },
      ),
    );
  }
}

class _TopProductCard extends StatelessWidget {
  final ProductSummary product;

  const _TopProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.gray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.inventory, size: 40),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${product.totalQuantity ?? 0} sold',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.placeholder,
                    ),
                  ),
                  const Icon(Icons.trending_up,
                      size: 16, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.placeholder),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

