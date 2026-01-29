class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      image: json['image'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }
}
