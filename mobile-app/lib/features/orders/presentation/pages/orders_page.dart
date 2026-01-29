import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../ecommerce/core/ecommerce_theme.dart';
import '../../../ecommerce/data/models/order_model.dart';
import '../../../ecommerce/data/repositories/ecommerce_repository.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final EcommerceRepository _repo = EcommerceRepository();
  List<OrderModel> _orders = [];
  Map<String, dynamic> _pagination = {};
  bool _loading = true;
  String? _error;
  int _page = 1;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders({bool reset = false}) async {
    if (reset) _page = 1;
    setState(() {
      if (reset) _orders = [];
      _loading = true;
      _error = null;
    });
    try {
      final result = await _repo.getOrders(page: _page, limit: 15, status: _statusFilter);
      if (!mounted) return;
      final list = result['orders'] as List<OrderModel>? ?? [];
      final pag = result['pagination'] as Map<String, dynamic>? ?? {};
      setState(() {
        _orders = reset ? list : [..._orders, ...list];
        _pagination = pag;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered': return const Color(0xFF4CAF50);
      case 'shipped': return const Color(0xFF2196F3);
      case 'processing': return const Color(0xFF9C27B0);
      case 'confirmed': return const Color(0xFF03A9F4);
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EcommerceTheme.cream,
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(color: EcommerceTheme.textPrimary, fontWeight: FontWeight.w600)),
        backgroundColor: EcommerceTheme.cream,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop(), color: EcommerceTheme.greenDark),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list, color: EcommerceTheme.greenDark),
            onSelected: (v) {
              setState(() => _statusFilter = v);
              _loadOrders(reset: true);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('All')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'confirmed', child: Text('Confirmed')),
              const PopupMenuItem(value: 'shipped', child: Text('Shipped')),
              const PopupMenuItem(value: 'delivered', child: Text('Delivered')),
              const PopupMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _orders.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: EcommerceTheme.greenDark));
    }
    if (_error != null && _orders.isEmpty) {
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
              ElevatedButton(onPressed: () => _loadOrders(reset: true), style: ElevatedButton.styleFrom(backgroundColor: EcommerceTheme.greenDark), child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (_orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long_outlined, size: 64, color: EcommerceTheme.greenDark),
              const SizedBox(height: 24),
              const Text('No orders yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: EcommerceTheme.textPrimary)),
              const SizedBox(height: 8),
              Text('Your order history will appear here', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push('/products'),
                icon: const Icon(Icons.shopping_bag),
                label: const Text('Start Shopping'),
                style: ElevatedButton.styleFrom(backgroundColor: EcommerceTheme.greenDark, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _loadOrders(reset: true),
      color: EcommerceTheme.greenDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () => context.push('/order/${order.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('#${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: EcommerceTheme.textPrimary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: _statusColor(order.status).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text(order.status.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _statusColor(order.status))),
                        ),
                      ],
                    ),
                    if (order.createdAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _formatDate(order.createdAt!),
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text('${order.items.length} item(s)', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.w600, color: EcommerceTheme.textPrimary)),
                        Text('${AppConfig.currencySymbol}${order.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: EcommerceTheme.greenDark, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
