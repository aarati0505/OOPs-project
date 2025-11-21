import 'package:flutter/material.dart';
import 'package:grocery/core/constants/app_colors.dart';
import 'package:grocery/core/constants/app_defaults.dart';
import 'package:grocery/core/models/dummy_product_model.dart';
import 'package:grocery/core/models/order_model.dart';
import 'package:grocery/core/api/api_client.dart';
import 'package:grocery/core/constants/app_constants.dart';

/// Page for retailers to place wholesale orders to wholesalers
class CreateWholesaleOrderPage extends StatefulWidget {
  const CreateWholesaleOrderPage({super.key});

  @override
  State<CreateWholesaleOrderPage> createState() =>
      _CreateWholesaleOrderPageState();
}

class _CreateWholesaleOrderPageState extends State<CreateWholesaleOrderPage> {
  final List<_CartItem> _cartItems = [];
  bool _isLoading = false;

  double get _totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  void _addToCart(ProductModel product, int quantity) {
    setState(() {
      final existingIndex =
          _cartItems.indexWhere((item) => item.product.id == product.id);

      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity += quantity;
      } else {
        _cartItems.add(_CartItem(product: product, quantity: quantity));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to cart'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
    });
  }

  Future<void> _placeOrder() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final items = _cartItems
          .map((item) => OrderItem(
                productId: item.product.id,
                productName: item.product.name,
                productImage: item.product.images.isNotEmpty 
                    ? item.product.images[0] 
                    : item.product.cover,
                quantity: item.quantity,
                unitPrice: item.product.price,
                totalPrice: item.product.price * item.quantity,
                weight: item.product.weight,
              ))
          .toList();

      final response = await ApiClient.post(
        AppConstants.createWholesaleOrderEndpoint,
        token: 'YOUR_TOKEN_HERE',
        body: {
          'items': items.map((i) => i.toJson()).toList(),
          'paymentMethod': 'cash_on_delivery',
        },
      );

      ApiClient.handleResponse(response);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wholesale order placed successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wholesale Order'),
        actions: [
          if (_cartItems.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_cartItems.length} items',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _cartItems.isEmpty
                ? _buildEmptyCart()
                : _buildCartList(),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.placeholder,
          ),
          const SizedBox(height: 16),
          Text(
            'Your wholesale cart is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add products from wholesalers to start',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.placeholder,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/retailer/browse-wholesalers');
            },
            icon: const Icon(Icons.search),
            label: const Text('Browse Wholesaler Products'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDefaults.padding),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return _WholesaleCartItemCard(
          item: item,
          onRemove: () => _removeFromCart(index),
          onUpdateQuantity: (qty) => _updateQuantity(index, qty),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppDefaults.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.placeholder,
                          ),
                    ),
                    Text(
                      '\$${_totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _placeOrder,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isLoading ? 'Placing...' : 'Place Order'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItem {
  final ProductModel product;
  int quantity;

  _CartItem({required this.product, required this.quantity});
}

class _WholesaleCartItemCard extends StatelessWidget {
  final _CartItem item;
  final VoidCallback onRemove;
  final Function(int) onUpdateQuantity;

  const _WholesaleCartItemCard({
    required this.item,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDefaults.padding),
      child: Padding(
        padding: const EdgeInsets.all(AppDefaults.padding),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.gray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: (item.product.images.isNotEmpty || item.product.cover.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.product.images.isNotEmpty ? item.product.images[0] : item.product.cover,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.inventory),
            ),
            const SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)} per unit',
                    style: TextStyle(
                      color: AppColors.placeholder,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity Controls
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onTap: () =>
                            onUpdateQuantity(item.quantity - 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onTap: () =>
                            onUpdateQuantity(item.quantity + 1),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Remove Button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

