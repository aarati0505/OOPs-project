import 'package:flutter/material.dart';

import '../../../core/api/services/product_api_service.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/models/dummy_product_model.dart';
import '../../../core/routes/app_routes.dart';

class RetailerInventoryPage extends StatefulWidget {
  const RetailerInventoryPage({super.key});

  @override
  State<RetailerInventoryPage> createState() => _RetailerInventoryPageState();
}

class _RetailerInventoryPageState extends State<RetailerInventoryPage> {
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('📦 Fetching all products from marketplace...');
      
      // Fetch ALL products from API (not filtered by retailer)
      final response = await ProductApiService.getProducts(pageSize: 100);
      
      // Show all products in the marketplace
      final allProducts = response.data;
      
      print('✅ Loaded ${allProducts.length} products from MongoDB');
      
      setState(() {
        _products = allProducts;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading products: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showEditPriceDialog(ProductModel product) {
    final priceController = TextEditingController(text: product.price.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Price - ${product.name}'),
        content: TextField(
          controller: priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'New Price',
            prefixText: '₹',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(priceController.text);
              if (newPrice != null && newPrice > 0) {
                Navigator.pop(context);
                _updateProductPrice(product, newPrice);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid price')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProductPrice(ProductModel product, double newPrice) async {
    // TODO: Call API to update product price
    // For now, update locally
    setState(() {
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        // Update the price in the existing product
        _products[index].price = newPrice;
        _products[index].mainPrice = newPrice;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Price updated to ₹${newPrice.toStringAsFixed(2)}')),
    );
  }

  void _showDeleteConfirmation(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Product'),
        content: Text('Are you sure you want to remove "${product.name}" from the marketplace?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    // TODO: Call API to delete product
    // For now, remove locally
    setState(() {
      _products.removeWhere((p) => p.id == product.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} removed from marketplace')),
    );
  }

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
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, AppRoutes.addProduct);
                      if (result == true) {
                        // Reload products after adding
                        _loadProducts();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No products in your inventory'),
            const SizedBox(height: 8),
            const Text('Add products to start selling'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, AppRoutes.addProduct);
                if (result == true) {
                  // Reload products after adding
                  _loadProducts();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDefaults.padding),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppDefaults.padding),
            child: ListTile(
              leading: product.images.isNotEmpty
                  ? Image.network(
                      product.images.first,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.inventory_2, size: 50),
                    )
                  : const Icon(Icons.inventory_2, size: 50),
              title: Text(product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Price: ₹${product.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: product.stock > 10
                          ? Colors.green.withOpacity(0.15)
                          : product.stock > 0
                              ? Colors.orange.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: product.stock > 10
                            ? Colors.green
                            : product.stock > 0
                                ? Colors.orange
                                : Colors.red,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Qty Available: ${product.stock}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: product.stock > 10
                            ? Colors.green[700]
                            : product.stock > 0
                                ? Colors.orange[700]
                                : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
              trailing: SizedBox(
                width: 120,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (product.stock <= 10)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.warning, color: Colors.orange, size: 18),
                      ),
                    // Edit Price Button
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showEditPriceDialog(product),
                      tooltip: 'Edit Price',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    // Delete Button
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => _showDeleteConfirmation(product),
                      tooltip: 'Remove',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              onTap: () {
                // TODO: Navigate to product details/edit page
                Navigator.pushNamed(
                  context,
                  AppRoutes.productDetails,
                  arguments: product,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

