/// Dynamic shop page config from admin (API).

class HeroBannerItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String promoCode;
  final String ctaText;
  final String ctaLink;
  final int order;

  HeroBannerItem({
    this.title = '',
    this.subtitle = '',
    this.imageUrl = '',
    this.promoCode = '',
    this.ctaText = 'Try Now',
    this.ctaLink = '',
    this.order = 0,
  });

  factory HeroBannerItem.fromJson(Map<String, dynamic> json) {
    return HeroBannerItem(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      promoCode: json['promoCode']?.toString() ?? '',
      ctaText: json['ctaText']?.toString() ?? 'Try Now',
      ctaLink: json['ctaLink']?.toString() ?? '',
      order: (json['order'] ?? 0) as int,
    );
  }
}

class FeatureItem {
  final String title;
  final String iconName;
  final int order;

  FeatureItem({this.title = '', this.iconName = 'eco', this.order = 0});

  factory FeatureItem.fromJson(Map<String, dynamic> json) {
    return FeatureItem(
      title: json['title']?.toString() ?? '',
      iconName: json['iconName']?.toString() ?? 'eco',
      order: (json['order'] ?? 0) as int,
    );
  }
}

class SectionItem {
  final String key;
  final String title;
  final String type; // latest, category
  final String? categoryId;
  final int limit;
  final int order;

  SectionItem({
    required this.key,
    required this.title,
    this.type = 'latest',
    this.categoryId,
    this.limit = 10,
    this.order = 0,
  });

  factory SectionItem.fromJson(Map<String, dynamic> json) {
    return SectionItem(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? 'latest',
      categoryId: json['categoryId']?.toString(),
      limit: (json['limit'] ?? 10) as int,
      order: (json['order'] ?? 0) as int,
    );
  }
}

class ReviewItem {
  final String authorName;
  final String authorInitials;
  final String text;
  final String date;
  final int rating;
  final int order;

  ReviewItem({
    this.authorName = '',
    this.authorInitials = '',
    this.text = '',
    this.date = '',
    this.rating = 5,
    this.order = 0,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    return ReviewItem(
      authorName: json['authorName']?.toString() ?? '',
      authorInitials: json['authorInitials']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      rating: (json['rating'] ?? 5) as int,
      order: (json['order'] ?? 0) as int,
    );
  }
}

class ShopPageConfigModel {
  final String welcomeText;
  final List<HeroBannerItem> heroBanners;
  final List<FeatureItem> features;
  final List<SectionItem> sections;
  final List<String> imageStripUrls;
  final String videoUrl;
  final String videoTitle;
  final List<ReviewItem> reviews;

  ShopPageConfigModel({
    this.welcomeText = 'Welcome to our store',
    this.heroBanners = const [],
    this.features = const [],
    this.sections = const [],
    this.imageStripUrls = const [],
    this.videoUrl = '',
    this.videoTitle = '',
    this.reviews = const [],
  });

  factory ShopPageConfigModel.fromJson(Map<String, dynamic> json) {
    final heroRaw = json['heroBanners'] as List<dynamic>? ?? [];
    final featRaw = json['features'] as List<dynamic>? ?? [];
    final secRaw = json['sections'] as List<dynamic>? ?? [];
    final stripRaw = json['imageStripUrls'] as List<dynamic>? ?? [];
    final revRaw = json['reviews'] as List<dynamic>? ?? [];
    return ShopPageConfigModel(
      welcomeText: json['welcomeText']?.toString() ?? 'Welcome to our store',
      heroBanners: heroRaw.map((e) => HeroBannerItem.fromJson(Map<String, dynamic>.from(e))).toList(),
      features: featRaw.map((e) => FeatureItem.fromJson(Map<String, dynamic>.from(e))).toList(),
      sections: secRaw.map((e) => SectionItem.fromJson(Map<String, dynamic>.from(e))).toList(),
      imageStripUrls: stripRaw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList(),
      videoUrl: json['videoUrl']?.toString() ?? '',
      videoTitle: json['videoTitle']?.toString() ?? '',
      reviews: revRaw.map((e) => ReviewItem.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }
}
