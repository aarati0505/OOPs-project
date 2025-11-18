import '../enums/user_role.dart';

class UserModel {
  String id;
  String name;
  String email;
  String phoneNumber;
  UserRole role;
  String? profileImageUrl;
  Map<String, dynamic>? location; // {latitude: double, longitude: double, address: String}
  String? businessName; // For retailers and wholesalers
  String? businessAddress;
  bool isEmailVerified;
  bool isPhoneVerified;
  DateTime createdAt;
  DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.profileImageUrl,
    this.location,
    this.businessName,
    this.businessAddress,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'profileImageUrl': profileImageUrl,
      'location': location,
      'businessName': businessName,
      'businessAddress': businessAddress,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      profileImageUrl: json['profileImageUrl'],
      location: json['location'],
      businessName: json['businessName'],
      businessAddress: json['businessAddress'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
    );
  }
}

