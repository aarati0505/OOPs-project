import '../enums/dummy_order_status.dart';
import '../enums/user_role.dart';

enum PaymentMethod { card, cash_on_delivery, paypal, wallet, razorpay }

enum PaymentStatus { pending, completed, failed, refunded }

class OrderModel {
  String id;
  String userId;
  UserRole userRole; // Customer, Retailer, or Wholesaler
  
  // Order details
  List<OrderItem> items;
  double totalAmount;
  double? discountAmount;
  double finalAmount;
  
  // Shipping information
  Map<String, dynamic>? deliveryAddress;
  DateTime? scheduledDeliveryDate; // For offline orders with calendar
  String? deliveryInstructions;
  
  // Payment information
  PaymentMethod paymentMethod;
  PaymentStatus paymentStatus;
  String? transactionId;
  
  // Order tracking
  OrderStatus status;
  DateTime createdAt;
  DateTime? updatedAt;
  DateTime? deliveredAt;
  
  // Retailer/Wholesaler specific
  String? retailerId; // If order is from customer to retailer
  String? retailerName;
  String? wholesalerId; // If order is from retailer to wholesaler
  String? wholesalerName;
  
  // Customer feedback
  bool hasFeedback;
  double? rating;
  String? feedbackComment;
  
  OrderModel({
    required this.id,
    required this.userId,
    required this.userRole,
    required this.items,
    required this.totalAmount,
    this.discountAmount,
    required this.finalAmount,
    this.deliveryAddress,
    this.scheduledDeliveryDate,
    this.deliveryInstructions,
    required this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.transactionId,
    this.status = OrderStatus.confirmed,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.retailerId,
    this.retailerName,
    this.wholesalerId,
    this.wholesalerName,
    this.hasFeedback = false,
    this.rating,
    this.feedbackComment,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userRole': userRole.name,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'deliveryAddress': deliveryAddress,
      'scheduledDeliveryDate': scheduledDeliveryDate?.toIso8601String(),
      'deliveryInstructions': deliveryInstructions,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'transactionId': transactionId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'retailerId': retailerId,
      'retailerName': retailerName,
      'wholesalerId': wholesalerId,
      'wholesalerName': wholesalerName,
      'hasFeedback': hasFeedback,
      'rating': rating,
      'feedbackComment': feedbackComment,
    };
  }

  // Create from JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userRole: UserRole.values.firstWhere(
        (e) => e.name == json['userRole'],
        orElse: () => UserRole.customer,
      ),
      items: (json['items'] as List? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      deliveryAddress: json['deliveryAddress'],
      scheduledDeliveryDate: json['scheduledDeliveryDate'] != null
          ? DateTime.parse(json['scheduledDeliveryDate'])
          : null,
      deliveryInstructions: json['deliveryInstructions'],
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.offline,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: json['transactionId'],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.confirmed,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      retailerId: json['retailerId'],
      retailerName: json['retailerName'],
      wholesalerId: json['wholesalerId'],
      wholesalerName: json['wholesalerName'],
      hasFeedback: json['hasFeedback'] ?? false,
      rating: json['rating']?.toDouble(),
      feedbackComment: json['feedbackComment'],
    );
  }
}

class OrderItem {
  String productId;
  String productName;
  String? productImage;
  int quantity;
  double unitPrice;
  double totalPrice;
  String? weight;

  OrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.weight,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'weight': weight,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'],
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      weight: json['weight'],
    );
  }
}

