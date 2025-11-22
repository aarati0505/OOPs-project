import 'package:flutter/material.dart';

import '../../core/api/services/product_api_service.dart';
import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/constants.dart';
import '../../core/models/dummy_product_model.dart';

class CategoryProductPage extends StatefulWidget {
  const CategoryProductPage({super.key});

  @override
  State<CategoryProductPage> createState() => _CategoryProductPageState();
}

class _CategoryProductPageState extends State<CategoryProductPage> {
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;
  String _categoryName = 'Category';
  String? _categoryId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get category info from route arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _categoryId = args['categoryId'] as String?;
      _categoryName = args['categoryName'] as String? ?? 'Category';
      
      if (_categoryId != null && _products.isEmpty && !_isLoading) {
        _loadProducts();
      } else if (_categoryId != null && _isLoading) {
        _loadProducts();
      }
    }
  }

  Future<void> _loadProducts() async {
    if (_categoryId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('📦 Fetching products for category: $_categoryName ($_categoryId)');
      
      final response = await ProductApiService.getProductsByCategory(
        categoryId: _categoryId!,
        pageSize: 50,
      );
      
      setState(() {
        _products = response.data;
        _isLoading = false;
      });
      
      print('✅ Loaded ${_products.length} products for category $_categoryName');
    } catch (e) {
      print('❌ Error loading products: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_categoryName),
        leading: const AppBackButton(),
      ),
      body: _buildBody(),
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
            Text('Error loading products'),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(fontSize: 12)),
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
            Text('No products in $_categoryName'),
            const SizedBox(height: 8),
            const Text('Check back later for new items'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppDefaults.padding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          return ProductTileSquare(
            data: _products[index],
          );
        },
      ),
    );
  }
}
