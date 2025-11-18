class ProductModel {
  String id;
  String name;
  String weight;
  String cover;
  List<String> images;
  double price;
  double mainPrice;
  String category;
  String? description;
  
  // Inventory management
  int stockQuantity;
  bool isAvailable;
  DateTime? availabilityDate; // For future availability
  bool isRegionSpecific; // For local products
  String? region; // Region name if region-specific
  
  // Retailer/Wholesaler relationship
  String retailerId; // ID of the retailer selling this
  String? retailerName;
  String? wholesalerId; // ID of wholesaler if product is via wholesaler
  String? wholesalerName;
  bool isViaWholesaler; // If retailer shows item available via wholesaler
  
  // Location for shop suggestions
  Map<String, dynamic>? shopLocation; // {latitude: double, longitude: double, address: String}
  double? distanceFromUser; // Distance in km
  
  // Product metadata
  DateTime createdAt;
  DateTime updatedAt;
  
  ProductModel({
    required this.id,
    required this.name,
    required this.weight,
    required this.cover,
    required this.images,
    required this.price,
    required this.mainPrice,
    required this.category,
    this.description,
    this.stockQuantity = 0,
    this.isAvailable = true,
    this.availabilityDate,
    this.isRegionSpecific = false,
    this.region,
    required this.retailerId,
    this.retailerName,
    this.wholesalerId,
    this.wholesalerName,
    this.isViaWholesaler = false,
    this.shopLocation,
    this.distanceFromUser,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'cover': cover,
      'images': images,
      'price': price,
      'mainPrice': mainPrice,
      'category': category,
      'description': description,
      'stockQuantity': stockQuantity,
      'isAvailable': isAvailable,
      'availabilityDate': availabilityDate?.toIso8601String(),
      'isRegionSpecific': isRegionSpecific,
      'region': region,
      'retailerId': retailerId,
      'retailerName': retailerName,
      'wholesalerId': wholesalerId,
      'wholesalerName': wholesalerName,
      'isViaWholesaler': isViaWholesaler,
      'shopLocation': shopLocation,
      'distanceFromUser': distanceFromUser,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      weight: json['weight'] ?? '',
      cover: json['cover'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      mainPrice: (json['mainPrice'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      description: json['description'],
      stockQuantity: json['stockQuantity'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      availabilityDate: json['availabilityDate'] != null
          ? DateTime.parse(json['availabilityDate'])
          : null,
      isRegionSpecific: json['isRegionSpecific'] ?? false,
      region: json['region'],
      retailerId: json['retailerId'] ?? '',
      retailerName: json['retailerName'],
      wholesalerId: json['wholesalerId'],
      wholesalerName: json['wholesalerName'],
      isViaWholesaler: json['isViaWholesaler'] ?? false,
      shopLocation: json['shopLocation'],
      distanceFromUser: json['distanceFromUser']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
