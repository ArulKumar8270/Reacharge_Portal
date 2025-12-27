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
    return Product(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discountPrice'] != null ? (json['discountPrice'] as num).toDouble() : null,
      images: List<String>.from(json['images'] ?? []),
      categoryId: json['categoryId'] ?? json['category_id'] ?? '',
      categoryName: json['categoryName'] ?? json['category_name'],
      stock: json['stock'] ?? 0,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['reviewCount'] ?? json['review_count'],
      specifications: json['specifications'],
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
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

