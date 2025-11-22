import 'package:flutter/material.dart';

import '../../core/api/services/category_api_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/constants.dart';
import '../../core/routes/app_routes.dart';
import 'components/category_tile.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'Choose a category',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          const CateogoriesGrid()
        ],
      ),
    );
  }
}

class CateogoriesGrid extends StatefulWidget {
  const CateogoriesGrid({
    super.key,
  });

  @override
  State<CateogoriesGrid> createState() => _CateogoriesGridState();
}

class _CateogoriesGridState extends State<CateogoriesGrid> {
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  String? _error;

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('📁 Fetching categories from MongoDB...');
      print('🔗 API URL: ${AppConstants.apiBaseUrl}${AppConstants.categoriesEndpoint}');
      
      final response = await CategoryApiService.getCategories();
      
      print('📦 Response success: ${response.success}');
      print('📦 Response data: ${response.data}');
      print('📦 Response message: ${response.message}');
      
      if (response.success && response.data != null) {
        setState(() {
          _categories = response.data!;
          _isLoading = false;
        });
        print('✅ Loaded ${_categories.length} categories');
      } else {
        throw Exception(response.message ?? 'Failed to load categories');
      }
    } catch (e, stackTrace) {
      print('❌ Error loading categories: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading categories...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load categories'),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCategories,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No categories available'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCategories,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return CategoryTile(
            imageLink: _getCategoryImage(category.name),
            label: category.name,
            backgroundColor: _getCategoryColor(index),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.categoryDetails,
                arguments: {
                  'categoryId': category.id,
                  'categoryName': category.name,
                },
              );
            },
          );
        },
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppColors.primary,
      const Color(0xFFE8F5E9),
      const Color(0xFFFFF3E0),
      const Color(0xFFE3F2FD),
      const Color(0xFFFCE4EC),
      const Color(0xFFF3E5F5),
      const Color(0xFFE0F2F1),
      const Color(0xFFFFF9C4),
    ];
    return colors[index % colors.length];
  }

  String _getCategoryImage(String categoryName) {
    // Map category names to original image URLs
    final categoryImages = {
      'Fruits & Vegetables': 'https://i.imgur.com/tGChxbZ.png',
      'Dairy & Eggs': 'https://i.imgur.com/yOFxoIP.png',
      'Bakery': 'https://i.imgur.com/GPsRaFC.png',
      'Meat & Seafood': 'https://i.imgur.com/mGRqfnc.png',
      'Beverages': 'https://i.imgur.com/fwyz4oC.png',
      'Snacks': 'https://i.imgur.com/DNr8a6R.png',
      'Pantry': 'https://i.imgur.com/O2ZX5nR.png',
      'Personal Care': 'https://i.imgur.com/wJBopjL.png',
    };

    // Return mapped image or default
    return categoryImages[categoryName] ?? 'https://i.imgur.com/m65fusg.png';
  }
}
