import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/cart_provider.dart';
import '../../core/ecommerce_theme.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/ecommerce_repository.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final EcommerceRepository _repo = EcommerceRepository();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        _nameController.text = auth.user!.name;
        _phoneController.text = auth.user!.phoneNumber;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    if (cart.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cart is empty'), behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = cart.cartItems.map((e) => {'product': e.product.id, 'quantity': e.quantity}).toList();
      final address = ShippingAddressModel(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim().isEmpty ? null : _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
      );
      final createdOrder = await _repo.createOrder(items: items, shippingAddress: address, paymentMethod: 'cod');
      if (!mounted) return;
      cart.clearCart();
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed! #${createdOrder.orderNumber}'), backgroundColor: EcommerceTheme.greenLight, behavior: SnackBarBehavior.floating),
      );
      context.go('/order/${createdOrder.id}');
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
        title: const Text('Checkout', style: TextStyle(color: EcommerceTheme.textPrimary, fontWeight: FontWeight.w600)),
        backgroundColor: EcommerceTheme.cream,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop(), color: EcommerceTheme.greenDark),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.cartItems.isEmpty && !_loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty'),
                  const SizedBox(height: 16),
                  TextButton(onPressed: () => context.push('/products'), child: const Text('Browse Products')),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
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
                          const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: EcommerceTheme.textPrimary)),
                          const SizedBox(height: 12),
                          ...cart.cartItems.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text('${e.product.name} x ${e.quantity}', style: TextStyle(fontSize: 14, color: Colors.grey[700]), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                Text('${AppConfig.currencySymbol}${e.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('${AppConfig.currencySymbol}${cart.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: EcommerceTheme.greenDark)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Shipping Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: EcommerceTheme.textPrimary)),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(labelText: 'Phone *', border: OutlineInputBorder()),
                            keyboardType: TextInputType.phone,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _addressLine1Controller,
                            decoration: const InputDecoration(labelText: 'Address Line 1 *', border: OutlineInputBorder()),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _addressLine2Controller,
                            decoration: const InputDecoration(labelText: 'Address Line 2 (optional)', border: OutlineInputBorder()),
                            maxLines: 1,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _cityController,
                                  decoration: const InputDecoration(labelText: 'City *', border: OutlineInputBorder()),
                                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _stateController,
                                  decoration: const InputDecoration(labelText: 'State', border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _pincodeController,
                            decoration: const InputDecoration(labelText: 'Pincode *', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 22),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 14))),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EcommerceTheme.greenDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      child: _loading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Place Order'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
