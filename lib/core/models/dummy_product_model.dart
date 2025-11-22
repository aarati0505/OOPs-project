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
  
  // Proxy inventory fields (NEW)
  String? sourceType; // "retailer" or "wholesaler" - for proxy products
  String? sourceProductId; // Reference to original wholesaler product if imported
  
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
    this.sourceType,
    this.sourceProductId,
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
      'sourceType': sourceType,
      'sourceProductId': sourceProductId,
      'shopLocation': shopLocation,
      'distanceFromUser': distanceFromUser,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle both backend API format and local format
    final imageUrl = json['imageUrl'] ?? json['cover'] ?? '';
    final List<String> imagesList = json['images'] != null 
        ? List<String>.from(json['images'] as List)
        : (imageUrl.isNotEmpty ? <String>[imageUrl] : <String>[]);
    
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Product',
      weight: json['weight']?.toString() ?? json['unit']?.toString() ?? 'N/A',
      cover: imageUrl,
      images: imagesList,
      price: (json['price'] ?? 0).toDouble(),
      mainPrice: (json['mainPrice'] ?? json['price'] ?? 0).toDouble(),
      category: json['category']?.toString() ?? 'Uncategorized',
      description: json['description']?.toString(),
      stockQuantity: json['stockQuantity'] ?? json['stock'] ?? 0,
      isAvailable: json['isAvailable'] ?? json['inStock'] ?? true,
      availabilityDate: json['availabilityDate'] != null
          ? DateTime.tryParse(json['availabilityDate'])
          : null,
      isRegionSpecific: json['isRegionSpecific'] ?? false,
      region: json['region']?.toString(),
      retailerId: json['retailerId']?.toString() ?? '',
      retailerName: json['retailerName']?.toString(),
      wholesalerId: json['wholesalerId']?.toString(),
      wholesalerName: json['wholesalerName']?.toString(),
      isViaWholesaler: json['isViaWholesaler'] ?? false,
      sourceType: json['sourceType']?.toString(),
      sourceProductId: json['sourceProductId']?.toString(),
      shopLocation: json['shopLocation'],
      distanceFromUser: json['distanceFromUser']?.toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
  
  // Convenience getters for compatibility
  int get stock => stockQuantity;
  String? get imageUrl => images.isNotEmpty ? images[0] : cover;
}
