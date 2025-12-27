import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Product List Page',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Coming Soon'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/cart'),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('View Cart'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/orders'),
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('My Orders'),
            ),
          ],
        ),
      ),
    );
  }
}

