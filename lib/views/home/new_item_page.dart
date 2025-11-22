import 'package:flutter/material.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/product_tile_square.dart';
import '../../core/constants/constants.dart';
import '../../core/api/services/product_api_service.dart';
import '../../core/models/dummy_product_model.dart';

class NewItemsPage extends StatefulWidget {
  const NewItemsPage({super.key});

  @override
  State<NewItemsPage> createState() => _NewItemsPageState();
}

class _NewItemsPageState extends State<NewItemsPage> {
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      print('🛒 Fetching all products for new items page...');
      final response = await ProductApiService.getProducts(pageSize: 50);
      
      setState(() {
        _products = response.data;
        _isLoading = false;
      });
      
      print('✅ Loaded ${_products.length} products');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Items'),
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No products available'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProducts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
                    child: GridView.builder(
                      padding: const EdgeInsets.only(top: AppDefaults.padding),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 0.64,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        return ProductTileSquare(
                          data: _products[index],
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
