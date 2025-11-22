import 'package:flutter/material.dart';

import '../../../core/api/services/product_api_service.dart';
import '../../../core/components/product_tile_square.dart';
import '../../../core/components/title_and_action_button.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/constants.dart';
import '../../../core/models/dummy_product_model.dart';
import '../../../core/routes/app_routes.dart';

class OurNewItem extends StatefulWidget {
  const OurNewItem({
    super.key,
  });

  @override
  State<OurNewItem> createState() => _OurNewItemState();
}

class _OurNewItemState extends State<OurNewItem> {
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      print('🛒 Fetching products for customer home...');
      print('🔗 API URL: ${AppConstants.apiBaseUrl}${AppConstants.productsEndpoint}');
      
      final response = await ProductApiService.getProducts(pageSize: 10);
      
      print('📦 Response data count: ${response.data.length}');
      print('📦 Total items: ${response.totalItems}');
      
      setState(() {
        _products = response.data;
        _isLoading = false;
      });
      
      print('✅ Loaded ${_products.length} products from MongoDB');
      
      if (_products.isEmpty) {
        print('⚠️ No products returned from API');
      } else {
        print('📦 First product: ${_products[0].name} - ₹${_products[0].price}');
      }
    } catch (e, stackTrace) {
      print('❌ Error loading products: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _products = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleAndActionButton(
          title: 'Our New Item',
          onTap: () => Navigator.pushNamed(context, AppRoutes.newItems),
        ),
        _isLoading
            ? const Padding(
                padding: EdgeInsets.all(AppDefaults.padding),
                child: Center(child: CircularProgressIndicator()),
              )
            : _products.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppDefaults.padding * 2),
                    child: Column(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('No products available'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _loadProducts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(left: AppDefaults.padding),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        _products.length,
                        (index) => ProductTileSquare(data: _products[index]),
                      ),
                    ),
                  ),
      ],
    );
  }
}
