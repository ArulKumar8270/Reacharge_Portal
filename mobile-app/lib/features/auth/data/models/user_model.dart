class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profileImage;
  final DateTime createdAt;
  final bool isVerified;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? pincode;
  final String? referralCode;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profileImage,
    required this.createdAt,
    required this.isVerified,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.pincode,
    this.referralCode,
  });

  String get formattedAddress {
    final parts = [addressLine1, addressLine2, city, state, pincode].where((e) => e != null && e.toString().trim().isNotEmpty).map((e) => e!.trim()).toList();
    return parts.isEmpty ? 'N/A' : parts.join(', ');
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone_number'] ?? '',
      profileImage: json['profileImage'] ?? json['profile_image'],
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      isVerified: json['isVerified'] ?? json['is_verified'] ?? false,
      addressLine1: json['addressLine1'] ?? json['address_line1'],
      addressLine2: json['addressLine2'] ?? json['address_line2'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      referralCode: json['referralCode'] ?? json['referral_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'referralCode': referralCode,
    };
  }
}

