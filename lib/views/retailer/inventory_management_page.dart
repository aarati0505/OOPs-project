import 'package:flutter/material.dart';
import 'package:grocery/core/constants/app_colors.dart';
import 'package:grocery/core/constants/app_defaults.dart';
import 'package:grocery/core/models/dummy_product_model.dart';
import 'package:grocery/core/api/api_client.dart';
import 'package:grocery/core/constants/app_constants.dart';
import 'package:grocery/views/shared/components/status_badge.dart';

/// Enhanced Inventory Management showing both owned and proxy products
class InventoryManagementPage extends StatefulWidget {
  const InventoryManagementPage({super.key});

  @override
  State<InventoryManagementPage> createState() =>
      _InventoryManagementPageState();
}

class _InventoryManagementPageState extends State<InventoryManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<ProductModel> _allProducts = [];
  List<ProductModel> _ownedProducts = [];
  List<ProductModel> _importedProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInventory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.get(
        AppConstants.inventoryEndpoint,
        token: 'YOUR_TOKEN_HERE',
      );

      final json = ApiClient.handleResponse(response);
      final data = json['data']['data'] as List;
      final products = data.map((e) => ProductModel.fromJson(e)).toList();

      setState(() {
        _allProducts = products;
        _ownedProducts = products
            .where((p) => p.sourceType == null || p.sourceType == 'retailer')
            .toList();
        _importedProducts =
            products.where((p) => p.sourceType == 'wholesaler').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load inventory: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldWithBoxBackground,
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filters
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Products'),
            Tab(text: 'Owned'),
            Tab(text: 'Imported'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInventory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildProductList(_allProducts),
                  _buildProductList(_ownedProducts),
                  _buildProductList(_importedProducts),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'import',
            onPressed: () {
              Navigator.pushNamed(context, '/retailer/import-wholesaler');
            },
            child: const Icon(Icons.cloud_download),
            backgroundColor: Colors.blue,
            mini: true,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () {
              // Navigate to add product
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 80, color: AppColors.placeholder),
            const SizedBox(height: 16),
            const Text('No products found'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDefaults.padding),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _InventoryProductCard(
          product: products[index],
          onTap: () {
            // Navigate to product details/edit
          },
          onUpdateStock: () => _showStockUpdateDialog(products[index]),
        );
      },
    );
  }

  Future<void> _showStockUpdateDialog(ProductModel product) async {
    final controller = TextEditingController(text: product.stockQuantity.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'New Stock Quantity',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(controller.text) ?? 0;
              Navigator.pop(context, qty);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await ApiClient.patch(
          '${AppConstants.updateStockEndpoint}/${product.id}',
          token: 'YOUR_TOKEN_HERE',
          body: {'quantity': result, 'operation': 'set'},
        );
        _loadInventory();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock updated successfully')),
        );
      } catch (e) {
        _showError('Failed to update stock: $e');
      }
    }
  }
}

class _InventoryProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onUpdateStock;

  const _InventoryProductCard({
    required this.product,
    required this.onTap,
    required this.onUpdateStock,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stockQuantity < 10;
    final isImported = product.sourceType == 'wholesaler';

    return Card(
      margin: const EdgeInsets.only(bottom: AppDefaults.padding),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppDefaults.borderRadius,
        side: BorderSide(
          color: isLowStock
              ? Colors.red.withOpacity(0.3)
              : AppColors.gray.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDefaults.borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            children: [
              Row(
                children: [
                  // Product Image
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.gray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: (product.images.isNotEmpty || product.cover.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.images.isNotEmpty ? product.images[0] : product.cover,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.inventory, size: 35),
                  ),
                  const SizedBox(width: 12),
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isImported) const ProxyBadge(isSmall: true),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (product.category != null)
                          Text(
                            product.category!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.placeholder,
                                ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                            const SizedBox(width: 16),
                            _StockIndicator(
                              stock: product.stockQuantity,
                              isLowStock: isLowStock,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onUpdateStock,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Update Stock'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isImported)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Order more from wholesaler
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text('Order More'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Edit product
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockIndicator extends StatelessWidget {
  final int stock;
  final bool isLowStock;

  const _StockIndicator({
    required this.stock,
    required this.isLowStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLowStock
            ? Colors.red.shade50
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLowStock ? Icons.warning : Icons.inventory_2,
            size: 14,
            color: isLowStock ? Colors.red.shade700 : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '$stock in stock',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isLowStock ? Colors.red.shade700 : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

