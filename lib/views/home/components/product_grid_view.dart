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
    } catch (e) {
      print('❌ Error loading products: $e');
      // Fallback to dummy data if API fails
      setState(() {
        _products = Dummy.products;
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
