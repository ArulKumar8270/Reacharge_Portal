import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../ecommerce/core/ecommerce_theme.dart';
import '../../../ecommerce/data/models/order_model.dart';
import '../../../ecommerce/data/repositories/ecommerce_repository.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final EcommerceRepository _repo = EcommerceRepository();
  OrderModel? _order;
  bool _loading = true;
  String? _error;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final order = await _repo.getOrderById(widget.orderId);
      if (mounted) setState(() {
        _order = order;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _cancelling = true);
    try {
      await _repo.cancelOrder(widget.orderId);
      if (!mounted) return;
      await _loadOrder();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order cancelled'), backgroundColor: EcommerceTheme.greenLight, behavior: SnackBarBehavior.floating));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
    } finally {
      if (mounted) setState(() => _cancelling = false);
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
        title: const Text('Order Details', style: TextStyle(color: EcommerceTheme.textPrimary, fontWeight: FontWeight.w600)),
        backgroundColor: EcommerceTheme.cream,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }, color: EcommerceTheme.greenDark),
      ),
      body: _buildBody(),
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
              ElevatedButton(onPressed: _loadOrder, style: ElevatedButton.styleFrom(backgroundColor: EcommerceTheme.greenDark), child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final order = _order!;
    final canCancel = order.status == 'pending' || order.status == 'confirmed';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#${order.orderNumber}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: EcommerceTheme.textPrimary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: _statusColor(order.status).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text(order.status.toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _statusColor(order.status))),
                      ),
                    ],
                  ),
                  if (order.createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_formatDate(order.createdAt!), style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: EcommerceTheme.textPrimary)),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ListTile(
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('Qty: ${item.quantity} × ${AppConfig.currencySymbol}${item.price.toStringAsFixed(0)}'),
                  trailing: Text('${AppConfig.currencySymbol}${item.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: EcommerceTheme.greenDark)),
                );
              },
            ),
          ),
          if (order.shippingAddress != null) ...[
            const SizedBox(height: 16),
            const Text('Shipping Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: EcommerceTheme.textPrimary)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${order.shippingAddress!.name}\n${order.shippingAddress!.phone}\n${order.shippingAddress!.addressLine1}\n${order.shippingAddress!.addressLine2 ?? ''}\n${order.shippingAddress!.city}${order.shippingAddress!.state != null ? ', ${order.shippingAddress!.state}' : ''} - ${order.shippingAddress!.pincode}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _row('Subtotal', order.subtotal),
                  if (order.shippingCost > 0) _row('Shipping', order.shippingCost),
                  if (order.tax > 0) _row('Tax', order.tax),
                  const Divider(),
                  _row('Total', order.total, bold: true),
                ],
              ),
            ),
          ),
          if (canCancel) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _cancelling ? null : _cancelOrder,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _cancelling ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Cancel Order'),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _row(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: EcommerceTheme.textPrimary)),
          Text('${AppConfig.currencySymbol}${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: bold ? 18 : 14, fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: bold ? EcommerceTheme.greenDark : EcommerceTheme.textPrimary)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
