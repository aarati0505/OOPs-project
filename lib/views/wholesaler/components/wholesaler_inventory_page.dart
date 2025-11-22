import 'package:flutter/material.dart';

import '../../../core/api/services/product_api_service.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/models/dummy_product_model.dart';
import '../../../core/routes/app_routes.dart';

class WholesalerInventoryPage extends StatefulWidget {
  const WholesalerInventoryPage({super.key});

  @override
  State<WholesalerInventoryPage> createState() => _WholesalerInventoryPageState();
}

class _WholesalerInventoryPageState extends State<WholesalerInventoryPage> {
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
      print('📦 Fetching all products from marketplace for wholesaler...');
      
      // Fetch ALL products from API (same as retailer)
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
        title: Text('Edit Wholesale Price - ${product.name}'),
        content: TextField(
          controller: priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'New Wholesale Price',
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
        _products[index].price = newPrice;
        _products[index].mainPrice = newPrice;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Wholesale price updated to ₹${newPrice.toStringAsFixed(2)}')),
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
                    'Wholesale Catalog',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, AppRoutes.addProduct);
                      if (result == true) {
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
            const Text('No products in catalog'),
            const SizedBox(height: 8),
            const Text('Add products to start selling to retailers'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, AppRoutes.addProduct);
                if (result == true) {
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
          // Wholesaler quantities are 10x larger than retail
          final wholesaleStock = product.stock * 10;
          // Wholesale price is 20% less than retail (bulk discount)
          final wholesalePrice = product.price * 0.8;
          
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
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '₹${wholesalePrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[600],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          '20% OFF',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: wholesaleStock > 100
                          ? Colors.green.withOpacity(0.15)
                          : wholesaleStock > 0
                              ? Colors.orange.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: wholesaleStock > 100
                            ? Colors.green
                            : wholesaleStock > 0
                                ? Colors.orange
                                : Colors.red,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Bulk Stock: $wholesaleStock units',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: wholesaleStock > 100
                            ? Colors.green[700]
                            : wholesaleStock > 0
                                ? Colors.orange[700]
                                : Colors.red[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Available for Retailers',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (wholesaleStock <= 100)
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

