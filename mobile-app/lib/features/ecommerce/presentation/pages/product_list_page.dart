import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../core/ecommerce_theme.dart';
import '../../data/models/shop_page_config_model.dart';
import '../../data/repositories/ecommerce_repository.dart';

// Placeholder images when product/banner images are missing (picsum.photos - no auth needed)
const _bannerPlaceholderUrl = 'https://picsum.photos/seed/nexus-banner/400/300';
const _productPlaceholderUrl = 'https://picsum.photos/seed/nexus-product/200/200';
const _stripPlaceholderUrls = [
  'https://picsum.photos/seed/nexus-strip1/400/200',
  'https://picsum.photos/seed/nexus-strip2/400/200',
  'https://picsum.photos/seed/nexus-strip3/400/200',
];

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final EcommerceRepository _repo = EcommerceRepository();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final GlobalKey _allProductsKey = GlobalKey();
  ShopPageConfigModel? _shopConfig;
  List<Product> _products = [];
  Map<String, List<Product>> _sectionProducts = {}; // section key -> products
  List<CategoryModel> _categories = [];
  Map<String, dynamic> _pagination = {};
  bool _loading = true;
  String? _error;
  int _page = 1;
  int _heroIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadShopConfigAndProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final list = await _repo.getCategories();
      if (mounted) setState(() => _categories = list);
    } catch (_) {}
  }

  Future<void> _loadShopConfigAndProducts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final config = await _repo.getShopConfig();
      if (!mounted) return;
      setState(() => _shopConfig = config);
      await _loadProducts(reset: true);
      await _loadSectionProducts();
    } catch (e) {
      if (mounted) setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadSectionProducts() async {
    final config = _shopConfig;
    if (config == null || config.sections.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final Map<String, List<Product>> sectionProducts = {};
    for (final section in config.sections) {
      List<Product> list;
      try {
        // Prefer products tagged for this section (bestsellers, family_pack, favourites)
        final result = await _repo.getProducts(page: 1, limit: section.limit, section: section.key);
        list = result['products'] as List<Product>? ?? [];
        // Fallback: if none tagged, use category or latest
        if (list.isEmpty) {
          if (section.type == 'category' && section.categoryId != null && section.categoryId!.isNotEmpty) {
            final fallback = await _repo.getProducts(page: 1, limit: section.limit, category: section.categoryId);
            list = fallback['products'] as List<Product>? ?? [];
          } else {
            final fallback = await _repo.getProducts(page: 1, limit: section.limit);
            list = fallback['products'] as List<Product>? ?? [];
          }
        }
      } catch (_) {
        list = [];
      }
      sectionProducts[section.key] = list;
    }
    if (mounted) setState(() {
      _sectionProducts = sectionProducts;
      _loading = false;
    });
  }

  Future<void> _loadProducts({bool reset = false}) async {
    if (reset) _page = 1;
    setState(() {
      if (reset) _products = [];
      _error = null;
    });
    try {
      final result = await _repo.getProducts(page: _page, limit: 24);
      if (!mounted) return;
      final list = result['products'] as List<Product>? ?? [];
      final pag = result['pagination'] as Map<String, dynamic>? ?? {};
      setState(() {
        _products = reset ? list : [..._products, ...list];
        _pagination = pag;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _scrollToAllProducts() {
    final ctx = _allProductsKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  List<Widget> _buildDynamicSections() {
    final config = _shopConfig;
    final list = <Widget>[];
    list.add(_buildWelcomeBar(config?.welcomeText ?? 'Welcome to our store'));
    list.add(_buildHeroBanner(config?.heroBanners));
    list.add(_buildFeatureIcons(config?.features));
    if (config?.sections != null && config!.sections.isNotEmpty) {
      for (final section in config.sections) {
        final products = _sectionProducts[section.key] ?? [];
        final isLast = section.key == config.sections.last.key;
        if (isLast) {
          list.add(_buildSectionTitleWithViewAll(section.title));
        } else {
          list.add(_buildSectionTitle(section.title));
        }
        list.add(_buildProductCarousel(products));
      }
    } else {
      list.add(_buildSectionTitle("Bestsellers You'll Love"));
      list.add(_buildProductCarousel(_products.take(10).toList()));
      list.add(_buildSectionTitle('Family Pack Collection'));
      list.add(_buildProductCarousel(_products.length > 10 ? _products.skip(10).take(10).toList() : _products));
      list.add(_buildSectionTitleWithViewAll('All-Time Favourite Collection'));
      list.add(_buildProductCarousel(_products.take(8).toList()));
    }
    list.add(_buildImageStrip(config?.imageStripUrls));
    list.add(_buildVideoSection(config?.videoUrl, config?.videoTitle));
    list.add(_buildCustomerReviews(config?.reviews));
    list.add(_buildAllProductsSection());
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EcommerceTheme.cream,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          if (_loading && _products.isEmpty)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: EcommerceTheme.greenDark)))
          else if (_error != null && _products.isEmpty)
            SliverFillRemaining(
              child: _buildError(),
            )
          else
            SliverList(
              delegate: SliverChildListDelegate(_buildDynamicSections()),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      backgroundColor: EcommerceTheme.cream,
      elevation: 0,
      title: const Text('Nexus MI', style: TextStyle(color: EcommerceTheme.greenDark, fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(icon: const Icon(Icons.search, color: EcommerceTheme.greenDark), onPressed: () => _showSearch(context)),
        IconButton(icon: const Icon(Icons.person_outline, color: EcommerceTheme.greenDark), onPressed: () => context.push('/profile')),
        Consumer<CartProvider>(
          builder: (_, cart, __) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: EcommerceTheme.greenDark), onPressed: () => context.push('/cart')),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Center(child: Text('${cart.itemCount > 9 ? "9+" : cart.itemCount}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black))),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeBar(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: EcommerceTheme.greenDark,
      child: Center(child: Text(text.isEmpty ? 'Welcome to our store' : text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
    );
  }

  Widget _buildHeroBanner(List<HeroBannerItem>? banners) {
    final list = banners != null && banners.isNotEmpty ? banners : [HeroBannerItem(title: 'From Our Farm to Your Kitchen.', promoCode: 'Get 5% Off | Use code - NEXUS5', ctaText: 'Try Now')];
    final hero = list[_heroIndex.clamp(0, list.length - 1)];
    final imageUrl = hero.imageUrl.isNotEmpty ? hero.imageUrl : (_products.isNotEmpty && _products.first.images.isNotEmpty ? _products.first.images.first : _bannerPlaceholderUrl);
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        color: EcommerceTheme.greenDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(hero.title.isEmpty ? 'From Our Farm to Your Kitchen.' : hero.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                        if (hero.promoCode.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(8)),
                            child: Text(hero.promoCode, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Material(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.play_arrow, color: Colors.black87), const SizedBox(width: 6), Text(hero.ctaText.isEmpty ? 'Try Now' : hero.ctaText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87))])),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Padding(
                  padding: const EdgeInsets.only(right: 24, top: 16, bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: 120,
                      height: 168,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null ? child : Container(width: 120, height: 168, color: EcommerceTheme.greenLight, child: const Center(child: CircularProgressIndicator(color: Colors.white54))),
                      errorBuilder: (_, __, ___) => Image.network(_bannerPlaceholderUrl, width: 120, height: 168, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 120, height: 168, color: EcommerceTheme.greenLight, child: const Icon(Icons.shopping_bag, size: 60, color: Colors.white54))),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (list.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(list.length, (i) => GestureDetector(onTap: () => setState(() => _heroIndex = i), child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: i == _heroIndex ? Colors.white : Colors.white38)))),
              ),
            ),
        ],
      ),
    );
  }

  static IconData _iconFromName(String name) {
    switch (name.toLowerCase()) {
      case 'agriculture': return Icons.agriculture;
      case 'water_drop':
      case 'water_drop_outlined': return Icons.water_drop_outlined;
      case 'eco': return Icons.eco;
      case 'workspace_premium': return Icons.workspace_premium;
      case 'local_florist': return Icons.local_florist;
      case 'spa': return Icons.spa;
      default: return Icons.eco;
    }
  }

  Widget _buildFeatureIcons(List<FeatureItem>? features) {
    final items = features != null && features.isNotEmpty
        ? features.map((f) => (f.title, _iconFromName(f.iconName))).toList()
        : [
            ('Wood-Pressed Tradition', Icons.agriculture),
            ('Small-Batch Pressed', Icons.water_drop_outlined),
            ('Pure & Unrefined', Icons.eco),
            ('Five-Generation Craft', Icons.workspace_premium),
          ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Traditional Chokku Extraction', style: TextStyle(color: EcommerceTheme.greenDark, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.take(4).map((e) => Expanded(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: EcommerceTheme.creamDark, shape: BoxShape.circle, border: Border.all(color: EcommerceTheme.greenDark.withOpacity(0.3))),
                    child: Icon(e.$2, color: EcommerceTheme.greenDark, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(e.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF424242)), maxLines: 2),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(title, style: const TextStyle(color: EcommerceTheme.greenDark, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSectionTitleWithViewAll(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: EcommerceTheme.greenDark, fontSize: 20, fontWeight: FontWeight.bold))),
          TextButton(onPressed: _scrollToAllProducts, child: const Text('View all', style: TextStyle(color: EcommerceTheme.greenDark, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildProductCarousel(List<Product> items) {
    if (items.isEmpty) return const SizedBox(height: 180, child: Center(child: Text('No products yet')));
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _ShopProductCard(product: items[index], width: 160),
        ),
      ),
    );
  }

  Widget _buildImageStrip(List<String>? urls) {
    final list = urls != null && urls.isNotEmpty ? urls : _stripPlaceholderUrls;
    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          for (int i = 0; i < list.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            _stripImage(list[i]),
          ],
        ],
      ),
    );
  }

  Widget _stripImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 200,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null ? child : Container(color: EcommerceTheme.creamDark, child: const Center(child: CircularProgressIndicator(color: EcommerceTheme.greenDark))),
          errorBuilder: (_, __, ___) => Container(width: 200, color: EcommerceTheme.creamDark, child: const Center(child: Icon(Icons.image_outlined, size: 48, color: EcommerceTheme.greenDark))),
        ),
      ),
    );
  }

  Widget _buildVideoSection(String? videoUrl, String? videoTitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      decoration: BoxDecoration(color: EcommerceTheme.greenDark.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: videoUrl != null && videoUrl.isNotEmpty
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.play_circle_filled, size: 64, color: EcommerceTheme.greenDark),
                if (videoTitle != null && videoTitle.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(videoTitle, style: const TextStyle(color: EcommerceTheme.greenDark, fontWeight: FontWeight.w600))),
              ])
            : const Icon(Icons.play_circle_filled, size: 64, color: EcommerceTheme.greenDark),
      ),
    );
  }

  Widget _buildCustomerReviews(List<ReviewItem>? reviews) {
    final list = reviews != null && reviews.isNotEmpty
        ? reviews
        : [
            ReviewItem(authorInitials: 'NS', authorName: 'Nandan S', text: 'We have been using Nexus Wood Pressed Oil and it is exceptionally pure and hygienic. Highly recommended.', date: 'Jan 15, 2024', rating: 5),
            ReviewItem(authorInitials: 'KS', authorName: 'Karthika S', text: 'The aroma of their groundnut oils adds a rich flavour to all my dishes. My family loves the taste.', date: 'Aug 10, 2023', rating: 5),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text('Customer reviews', style: TextStyle(color: EcommerceTheme.greenDark, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 12), child: Text('See what our customers are saying.', style: TextStyle(color: Colors.grey, fontSize: 14))),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final r = list[index];
              return Container(
                width: MediaQuery.of(context).size.width * 0.85,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: List.generate(5, (_) => const Icon(Icons.star, size: 18, color: Colors.amber))),
                    const SizedBox(height: 12),
                    Text(r.text, style: const TextStyle(fontSize: 14, color: Color(0xFF424242), height: 1.4), maxLines: 4, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    Row(
                      children: [
                        CircleAvatar(radius: 16, backgroundColor: EcommerceTheme.greenDark, child: Text(r.authorInitials.isEmpty ? r.authorName.isNotEmpty ? r.authorName.substring(0, 1).toUpperCase() : '?' : r.authorInitials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.authorName, style: const TextStyle(fontWeight: FontWeight.w600, color: EcommerceTheme.greenDark)), Text(r.date, style: TextStyle(fontSize: 12, color: Colors.grey[600]))]),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAllProductsSection() {
    return Container(
      key: _allProductsKey,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Browse All Products', style: TextStyle(color: EcommerceTheme.greenDark, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_products.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No products available')))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
              itemCount: _products.length,
              itemBuilder: (context, index) => _ProductCard(product: _products[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => _loadShopConfigAndProducts(), style: ElevatedButton.styleFrom(backgroundColor: EcommerceTheme.greenDark), child: const Text('Retry')),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search products',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: (v) {
              Navigator.pop(ctx);
              if (v.trim().isNotEmpty) _scrollToAllProducts();
            },
          ),
        ),
      ),
    );
  }
}

class _ShopProductCard extends StatelessWidget {
  final Product product;
  final double width;

  const _ShopProductCard({required this.product, this.width = 160});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return InkWell(
          onTap: () => context.push('/product/${product.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Image.network(
                          imageUrl ?? _productPlaceholderUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) => progress == null ? child : Container(color: EcommerceTheme.creamDark, child: const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: EcommerceTheme.greenDark)))),
                          errorBuilder: (_, __, ___) => Image.network(_productPlaceholderUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: EcommerceTheme.creamDark, child: const Center(child: Icon(Icons.shopping_bag_outlined, size: 40, color: EcommerceTheme.greenDark)))),
                        ),
                      ),
                    ),
                    if (product.hasDiscount)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Sale', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF212121)), maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (product.rating != null) Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 4), Text('${product.rating!.toStringAsFixed(1)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])), if (product.reviewCount != null) Text(' (${product.reviewCount} reviews)', style: TextStyle(fontSize: 11, color: Colors.grey[600]))]),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text('${AppConfig.currencySymbol}${product.finalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: EcommerceTheme.greenDark)),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 6),
                            Text('${AppConfig.currencySymbol}${product.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Colors.grey[600], decoration: TextDecoration.lineThrough)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            cart.addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added ${product.name} to cart'), backgroundColor: EcommerceTheme.greenDark, behavior: SnackBarBehavior.floating));
                          },
                          icon: const Icon(Icons.shopping_cart, size: 16),
                          label: const Text('Add to cart'),
                          style: ElevatedButton.styleFrom(backgroundColor: EcommerceTheme.greenDark, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: EcommerceTheme.greenDark.withOpacity(0.1))),
      child: InkWell(
        onTap: () => context.push('/product/${product.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imageUrl ?? _productPlaceholderUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null ? child : Container(color: EcommerceTheme.creamDark, child: const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: EcommerceTheme.greenDark)))),
                  errorBuilder: (_, __, ___) => Image.network(_productPlaceholderUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: EcommerceTheme.creamDark, child: const Center(child: Icon(Icons.shopping_bag_outlined, size: 40, color: EcommerceTheme.greenDark)))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF212121)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('${AppConfig.currencySymbol}${product.finalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: EcommerceTheme.greenDark)),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text('${AppConfig.currencySymbol}${product.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Colors.grey[600], decoration: TextDecoration.lineThrough)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
