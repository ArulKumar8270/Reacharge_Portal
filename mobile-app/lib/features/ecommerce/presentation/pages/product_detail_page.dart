import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../core/ecommerce_theme.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/ecommerce_repository.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final EcommerceRepository _repo = EcommerceRepository();
  Product? _product;
  bool _loading = true;
  String? _error;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final product = await _repo.getProductById(widget.productId);
      if (mounted) setState(() {
        _product = product;
        _loading = false;
        _quantity = 1;
      });
    } catch (e) {
      if (mounted) setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EcommerceTheme.cream,
      appBar: AppBar(
        title: const Text('Product', style: TextStyle(color: EcommerceTheme.textPrimary, fontWeight: FontWeight.w600)),
        backgroundColor: EcommerceTheme.cream,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop(), color: EcommerceTheme.greenDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: EcommerceTheme.greenDark),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _product != null && _product!.isAvailable && _product!.stock > 0 ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: EcommerceTheme.greenDark));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadProduct, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final product = _product!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 280,
            width: double.infinity,
            child: product.images.isNotEmpty
                ? PageView.builder(
                    itemCount: product.images.length,
                    itemBuilder: (_, i) => Image.network(
                      product.images[i],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey)),
                    ),
                  )
                : const Center(child: Icon(Icons.image_outlined, size: 80, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.categoryName != null)
                  Text(
                    product.categoryName!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: EcommerceTheme.textPrimary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      '${AppConfig.currencySymbol}${product.finalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: EcommerceTheme.greenDark),
                    ),
                    if (product.hasDiscount) ...[
                      const SizedBox(width: 12),
                      Text(
                        '${AppConfig.currencySymbol}${product.price.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600], decoration: TextDecoration.lineThrough),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: EcommerceTheme.greenLight, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                if (product.description != null && product.description!.isNotEmpty)
                  Text(
                    product.description!,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Quantity:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          ),
                          SizedBox(width: 32, child: Center(child: Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)))),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: _quantity < product.stock ? () => setState(() => _quantity++) : null,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('Stock: ${product.stock}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -2))]),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () {
            final cart = context.read<CartProvider>();
            cart.addToCart(_product!, quantity: _quantity);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Added ${_product!.name} x $_quantity to cart'), backgroundColor: EcommerceTheme.greenLight, behavior: SnackBarBehavior.floating),
            );
            context.push('/cart');
          },
          icon: const Icon(Icons.shopping_cart),
          label: const Text('Add to Cart'),
          style: ElevatedButton.styleFrom(
            backgroundColor: EcommerceTheme.greenDark,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
