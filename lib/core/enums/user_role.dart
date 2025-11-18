/// User roles in the platform
enum UserRole {
  customer,
  retailer,
  wholesaler;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.retailer:
        return 'Retailer';
      case UserRole.wholesaler:
        return 'Wholesaler';
    }
  }

  String get description {
    switch (this) {
      case UserRole.customer:
        return 'Browse, search, and purchase products';
      case UserRole.retailer:
        return 'Manage inventory and sell to customers';
      case UserRole.wholesaler:
        return 'Supply products to retailers';
    }
  }
}

