class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final String categoryId;
  final String? categoryName;
  final int stock;
  final double? rating;
  final int? reviewCount;
  final Map<String, dynamic>? specifications;
  final bool isAvailable;
  final DateTime createdAt;
  
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    required this.categoryId,
    this.categoryName,
    required this.stock,
    this.rating,
    this.reviewCount,
    this.specifications,
    required this.isAvailable,
    required this.createdAt,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    final cat = json['category'];
    String categoryId = json['categoryId'] ?? json['category_id'] ?? '';
    String? categoryName = json['categoryName'] ?? json['category_name'];
    if (cat is Map) {
      categoryId = cat['_id'] ?? cat['id'] ?? categoryId;
      categoryName ??= cat['name'];
    }
    final imageList = json['images'] is List
        ? List<String>.from((json['images'] as List).map((e) => e.toString()))
        : <String>[];
    if (imageList.isEmpty && json['image'] != null) {
      imageList.add(json['image'].toString());
    }
    final stock = (json['stock'] ?? 0).toInt();
    final isActive = json['isActive'] ?? json['is_active'] ?? true;
    return Product(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['compareAtPrice'] != null ? (json['compareAtPrice'] as num).toDouble() : (json['discountPrice'] != null ? (json['discountPrice'] as num).toDouble() : null),
      images: imageList,
      categoryId: categoryId,
      categoryName: categoryName,
      stock: stock,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['reviewCount'] ?? json['review_count'],
      specifications: json['specifications'] is Map ? Map<String, dynamic>.from(json['specifications']) : null,
      isAvailable: isActive && stock >= 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'images': images,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
      'specifications': specifications,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  double get finalPrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((price - discountPrice!) / price) * 100;
  }
}

