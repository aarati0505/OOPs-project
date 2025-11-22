import 'package:flutter/material.dart';

import '../../../core/api/services/product_api_service.dart';
import '../../../core/components/product_tile_square.dart';
import '../../../core/constants/constants.dart';
import '../../../core/models/dummy_product_model.dart';

class ProductGridView extends StatefulWidget {
  const ProductGridView({
    super.key,
  });

  @override
  State<ProductGridView> createState() => _ProductGridViewState();
}

class _ProductGridViewState extends State<ProductGridView> {
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      print('🛒 Fetching products for grid view...');
      final response = await ProductApiService.getProducts(pageSize: 20);
      
      setState(() {
        _products = response.data;
        _isLoading = false;
      });
      
      print('✅ Loaded ${_products.length} products from MongoDB');
      if (_products.isNotEmpty) {
        print('📦 First product: ${_products[0].name} - ₹${_products[0].price}');
      }
    } catch (e) {
      print('❌ Error loading products: $e');
      setState(() {
        _products = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_products.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No products available'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadProducts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.only(top: AppDefaults.padding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          return ProductTileSquare(data: _products[index]);
        },
      ),
    );
  }
}
