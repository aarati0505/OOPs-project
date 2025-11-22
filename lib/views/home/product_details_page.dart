import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/components/app_back_button.dart';
import '../../core/components/buy_now_row_button.dart';
import '../../core/components/price_and_quantity.dart';
import '../../core/components/product_images_slider.dart';
import '../../core/components/review_row_button.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/models/dummy_product_model.dart';
import '../../core/models/review_model.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/api/services/review_api_service.dart';
import '../../core/services/local_auth_service.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = true;
  double _averageRating = 0;
  int _totalReviews = 0;

  void _incrementQuantity() {
    setState(() => _quantity++);
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _loadReviews(String productId) async {
    try {
      final reviews = await ReviewApiService.getProductReviews(productId, limit: 5);
      final stats = await ReviewApiService.getProductReviewStats(productId);
      
      setState(() {
        _reviews = reviews;
        _averageRating = stats?.averageRating ?? 0;
        _totalReviews = stats?.totalReviews ?? 0;
        _isLoadingReviews = false;
      });
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load reviews when page is built
    final product = ModalRoute.of(context)?.settings.arguments as ProductModel?;
    if (product != null && _isLoadingReviews) {
      _loadReviews(product.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get product from navigation arguments
    final product = ModalRoute.of(context)?.settings.arguments as ProductModel?;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('Product Details'),
        ),
        body: const Center(
          child: Text('Product not found'),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Product Details'),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
          child: BuyNowRow(
            onBuyButtonTap: () {
              // Add to cart and go to checkout
              final cart = Provider.of<CartProvider>(context, listen: false);
              for (int i = 0; i < _quantity; i++) {
                cart.addItem(product);
              }
              Navigator.pushNamed(context, AppRoutes.checkoutPage);
            },
            onCartButtonTap: () {
              // Add to cart
              final cart = Provider.of<CartProvider>(context, listen: false);
              for (int i = 0; i < _quantity; i++) {
                cart.addItem(product);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} added to cart'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'VIEW CART',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.cartPage);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Product Images
            ProductImagesSlider(
              images: product.images.isNotEmpty
                  ? product.images
                  : (product.cover.isNotEmpty
                      ? [product.cover, product.cover, product.cover]
                      : ['https://via.placeholder.com/400x400?text=No+Image']),
            ),
            
            // Product Name and Weight
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Weight: ${product.weight}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Price and Quantity
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
              child: PriceAndQuantityRow(
                currentPrice: product.price,
                orginalPrice: product.mainPrice,
                quantity: _quantity,
                onIncrement: _incrementQuantity,
                onDecrement: _decrementQuantity,
              ),
            ),
            const SizedBox(height: 16),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Details',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description ?? 'Fresh and high-quality ${product.name}. Perfect for your daily needs.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Additional Info
                  _buildInfoRow('Category', product.category),
                  const SizedBox(height: 8),
                  _buildInfoRow('Price', '₹${product.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Original Price', '₹${product.mainPrice.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Discount', '${((1 - product.price / product.mainPrice) * 100).toStringAsFixed(0)}% OFF'),
                ],
              ),
            ),

            // Reviews Section
            Padding(
              padding: const EdgeInsets.all(AppDefaults.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(thickness: 0.1),
                  const SizedBox(height: 16),
                  
                  // Reviews Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Customer Reviews',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (_totalReviews > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${_averageRating.toStringAsFixed(1)} ($_totalReviews)',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Reviews List
                  _isLoadingReviews
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _reviews.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.rate_review_outlined,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No reviews yet',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.submitReview,
                                        );
                                      },
                                      child: const Text('Be the first to review'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                ..._reviews.map((review) => _buildReviewCard(review)),
                                if (_totalReviews > _reviews.length)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: TextButton(
                                      onPressed: () {
                                        // TODO: Navigate to all reviews page
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Showing ${_reviews.length} of $_totalReviews reviews'),
                                          ),
                                        );
                                      },
                                      child: Text('View all $_totalReviews reviews'),
                                    ),
                                  ),
                              ],
                            ),
                  
                  const SizedBox(height: 16),
                  const Divider(thickness: 0.1),
                  
                  // Write Review Button
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showWriteReviewDialog(product),
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Write a Review'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            
            // Review Row Button
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDefaults.padding,
              ),
              child: ReviewRowButton(totalStars: 5),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Show dialog to write a review
  void _showWriteReviewDialog(ProductModel product) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Write a Review'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reviewing: ${product.name}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Rating selector
                const Text(
                  'Your Rating',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: isSubmitting ? null : () {
                        setDialogState(() {
                          selectedRating = index + 1;
                        });
                      },
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        size: 32,
                        color: Colors.amber,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                
                // Comment field
                const Text(
                  'Your Review',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commentController,
                  enabled: !isSubmitting,
                  decoration: const InputDecoration(
                    hintText: 'Share your experience with this product...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  maxLength: 500,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                final comment = commentController.text.trim();
                
                if (comment.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please write a review comment'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (comment.length < 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Review must be at least 10 characters'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                setDialogState(() {
                  isSubmitting = true;
                });

                try {
                  // Get user email from local storage
                  final user = await LocalAuthService.getLocalUser();
                  final userEmail = user?.email;

                  if (userEmail == null) {
                    setDialogState(() {
                      isSubmitting = false;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please login to submit a review'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  // Submit review
                  final result = await ReviewApiService.createReview(
                    productId: product.id,
                    rating: selectedRating,
                    comment: comment,
                    userEmail: userEmail,
                  );

                  if (result['success'] == true) {
                    Navigator.of(dialogContext).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Review submitted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Reload reviews
                    _loadReviews(product.id);
                  } else {
                    setDialogState(() {
                      isSubmitting = false;
                    });
                    
                    final errorMessage = result['message'] ?? 'Failed to submit review. Please try again.';
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: errorMessage.contains('already reviewed') 
                            ? Colors.orange 
                            : Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() {
                    isSubmitting = false;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer info and rating
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green.shade100,
                child: Text(
                  review.initials,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Name and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      review.relativeTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Rating stars
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Review comment
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
