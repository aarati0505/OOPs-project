import 'package:flutter/material.dart';
import 'package:grocery/core/constants/app_colors.dart';
import 'package:grocery/core/constants/app_defaults.dart';
import 'package:grocery/core/models/dummy_product_model.dart';
import 'package:grocery/core/api/api_client.dart';
import 'package:grocery/core/constants/app_constants.dart';
import 'package:grocery/views/shared/components/status_badge.dart';

/// Screen for retailers to browse and import wholesaler products
class ImportWholesalerProductPage extends StatefulWidget {
  const ImportWholesalerProductPage({super.key});

  @override
  State<ImportWholesalerProductPage> createState() =>
      _ImportWholesalerProductPageState();
}

class _ImportWholesalerProductPageState
    extends State<ImportWholesalerProductPage> {
  bool _isLoading = false;
  List<ProductModel> _products = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadWholesalerProducts();
  }

  Future<void> _loadWholesalerProducts({String? search}) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.get(
        AppConstants.productsEndpoint,
        token: 'YOUR_TOKEN_HERE',
        queryParameters: {
          'sourceType': 'wholesaler',
          if (search != null && search.isNotEmpty) 'search': search,
          if (_selectedCategory != null) 'category': _selectedCategory,
        },
      );

      final json = ApiClient.handleResponse(response);
      final data = json['data']['data'] as List;

      setState(() {
        _products = data.map((e) => ProductModel.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load products: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  Future<void> _importProduct(ProductModel product) async {
    // Show dialog to customize price and initial stock
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ImportDialog(product: product),
    );

    if (result == null) return;

    try {
      final response = await ApiClient.post(
        AppConstants.importFromWholesalerEndpoint,
        token: 'YOUR_TOKEN_HERE',
        body: {
          'productId': product.id,
          'stock': result['stock'],
          'price': result['price'],
        },
      );

      ApiClient.handleResponse(response);
      _showSuccess('Product imported successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showError('Failed to import product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Wholesaler'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search wholesaler products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: AppDefaults.borderRadius,
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) => _loadWholesalerProducts(search: value),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? _buildEmptyState()
              : _buildProductList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 80, color: AppColors.placeholder),
          const SizedBox(height: 16),
          Text(
            'No wholesaler products found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching or check back later',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.placeholder,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDefaults.padding),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _WholesalerProductCard(
          product: product,
          onImport: () => _importProduct(product),
        );
      },
    );
  }
}

class _WholesalerProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onImport;

  const _WholesalerProductCard({
    required this.product,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDefaults.padding),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppDefaults.borderRadius,
        side: BorderSide(color: AppColors.gray.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
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
                      : const Icon(Icons.inventory, size: 40),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (product.category != null)
                        Text(
                          product.category!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.placeholder,
                                  ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.warehouse,
                              size: 16, color: AppColors.placeholder),
                          const SizedBox(width: 4),
                          Text(
                            'Wholesaler Product',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall?.copyWith(
                                  color: AppColors.placeholder,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wholesale Price',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.placeholder,
                          ),
                    ),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Stock Available',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.placeholder,
                          ),
                    ),
                    Text(
                      '${product.stockQuantity} units',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onImport,
                icon: const Icon(Icons.cloud_download),
                label: const Text('Import to My Inventory'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportDialog extends StatefulWidget {
  final ProductModel product;

  const _ImportDialog({required this.product});

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  late TextEditingController _priceController;
  late TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _stockController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Your Selling Price',
                prefixText: '\$',
                helperText: 'Set your retail price',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Initial Stock',
                helperText: 'You can order from wholesaler later',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This product will appear in your inventory with a "Imported" badge.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'price': double.tryParse(_priceController.text) ?? widget.product.price,
              'stock': int.tryParse(_stockController.text) ?? 0,
            });
          },
          child: const Text('Import'),
        ),
      ],
    );
  }
}

