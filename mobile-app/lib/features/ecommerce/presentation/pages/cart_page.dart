import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../core/ecommerce_theme.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';

class CartPage extends StatelessWidget {
  final bool showBackButton;

  const CartPage({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EcommerceTheme.cream,
      appBar: AppBar(
        title: const Text('Cart', style: TextStyle(color: EcommerceTheme.textPrimary, fontWeight: FontWeight.w600)),
        backgroundColor: EcommerceTheme.cream,
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
        leading: showBackButton
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop(), color: EcommerceTheme.greenDark)
            : null,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.cartItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 80, color: Color(0xFF757575)),
                    const SizedBox(height: 24),
                    const Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: EcommerceTheme.textPrimary)),
                    const SizedBox(height: 8),
                    Text('Add items to get started', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/products'),
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Browse Products'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EcommerceTheme.greenDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => context.push('/orders'),
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('View Orders'),
                      style: TextButton.styleFrom(foregroundColor: EcommerceTheme.greenDark),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cart.cartItems[index];
                    return _CartItemCard(item: item, cart: cart);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -2))],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: EcommerceTheme.textPrimary)),
                          Text(
                            '${AppConfig.currencySymbol}${cart.totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: EcommerceTheme.greenDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push('/checkout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: EcommerceTheme.greenDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          child: const Text('Proceed to Checkout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartProvider cart;

  const _CartItemCard({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey))
                    : const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: EcommerceTheme.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${AppConfig.currencySymbol}${product.finalPrice.toStringAsFixed(0)} x ${item.quantity}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () => cart.updateQuantity(product.id, item.quantity - 1),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                            SizedBox(width: 24, child: Center(child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w600)))),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: product.stock > item.quantity ? () => cart.updateQuantity(product.id, item.quantity + 1) : null,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                        Text(
                          '${AppConfig.currencySymbol}${item.totalPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: EcommerceTheme.greenDark),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                        onPressed: () => cart.removeFromCart(product.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
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
