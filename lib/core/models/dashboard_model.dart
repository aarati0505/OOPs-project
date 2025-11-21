/// Dashboard Model for Retailer and Wholesaler analytics
class DashboardModel {
  final String role;
  final DashboardStats stats;
  final List<RecentOrder>? recentOrders;
  final List<ProductSummary>? lowStockProducts;
  final List<ProductSummary>? recommendedProducts;
  final List<ProductSummary>? topSellingProducts;
  final List<NotificationItem>? notifications;
  final List<OrderSummary>? recentCustomerOrders;
  final List<OrderSummary>? wholesaleOrders;

  DashboardModel({
    required this.role,
    required this.stats,
    this.recentOrders,
    this.lowStockProducts,
    this.recommendedProducts,
    this.topSellingProducts,
    this.notifications,
    this.recentCustomerOrders,
    this.wholesaleOrders,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      role: json['role'] ?? 'customer',
      stats: DashboardStats.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
      recentOrders: (json['recentOrders'] as List?)
          ?.map((e) => RecentOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
      lowStockProducts: (json['lowStockProducts'] as List?)
          ?.map((e) => ProductSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendedProducts: (json['recommendedProducts'] as List?)
          ?.map((e) => ProductSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      topSellingProducts: (json['topSellingProducts'] as List?)
          ?.map((e) => ProductSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      notifications: (json['notifications'] as List?)
          ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentCustomerOrders: (json['recentCustomerOrders'] as List?)
          ?.map((e) => OrderSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      wholesaleOrders: (json['wholesaleOrders'] as List?)
          ?.map((e) => OrderSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DashboardStats {
  // Common stats
  final int? totalOrders;
  final double? totalRevenue;
  final int? pendingOrders;
  final int? completedOrders;

  // Product stats
  final int? totalProducts;
  final int? inStock;
  final int? outOfStock;
  final double? totalInventoryValue;

  // Retailer specific
  final double? totalSpent;
  final int? deliveredOrders;

  // Wholesaler specific
  final int? totalRetailers;

  DashboardStats({
    this.totalOrders,
    this.totalRevenue,
    this.pendingOrders,
    this.completedOrders,
    this.totalProducts,
    this.inStock,
    this.outOfStock,
    this.totalInventoryValue,
    this.totalSpent,
    this.deliveredOrders,
    this.totalRetailers,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalOrders: json['totalOrders'] as int?,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble(),
      pendingOrders: json['pendingOrders'] as int?,
      completedOrders: json['completedOrders'] as int?,
      totalProducts: json['totalProducts'] as int?,
      inStock: json['inStock'] as int?,
      outOfStock: json['outOfStock'] as int?,
      totalInventoryValue: (json['totalInventoryValue'] as num?)?.toDouble(),
      totalSpent: (json['totalSpent'] as num?)?.toDouble(),
      deliveredOrders: json['deliveredOrders'] as int?,
      totalRetailers: json['totalRetailers'] as int?,
    );
  }
}

class RecentOrder {
  final String id;
  final double totalAmount;
  final String status;
  final int itemCount;
  final String createdAt;

  RecentOrder({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.itemCount,
    required this.createdAt,
  });

  factory RecentOrder.fromJson(Map<String, dynamic> json) {
    return RecentOrder(
      id: json['id'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      itemCount: json['itemCount'] as int? ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class ProductSummary {
  final String id;
  final String name;
  final double? price;
  final int? stock;
  final String? category;
  final String? imageUrl;
  final double? rating;
  final bool? inStock;
  final int? totalQuantity;
  final double? totalRevenue;

  ProductSummary({
    required this.id,
    required this.name,
    this.price,
    this.stock,
    this.category,
    this.imageUrl,
    this.rating,
    this.inStock,
    this.totalQuantity,
    this.totalRevenue,
  });

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble(),
      stock: json['stock'] as int?,
      category: json['category'] as String?,
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      inStock: json['inStock'] as bool?,
      totalQuantity: json['totalQuantity'] as int?,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble(),
    );
  }
}

class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String message;
  final String createdAt;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      type: json['type'] ?? 'system',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class OrderSummary {
  final String id;
  final String? customerName;
  final String? retailerName;
  final String? wholesalerName;
  final double totalAmount;
  final String status;
  final String createdAt;

  OrderSummary({
    required this.id,
    this.customerName,
    this.retailerName,
    this.wholesalerName,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id'] ?? '',
      customerName: json['customerName'] as String?,
      retailerName: json['retailerName'] as String?,
      wholesalerName: json['wholesalerName'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

