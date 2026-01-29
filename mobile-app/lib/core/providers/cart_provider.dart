import 'package:flutter/foundation.dart';
import '../../features/ecommerce/data/models/product_model.dart';
import '../../features/ecommerce/data/models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  
  List<CartItem> get cartItems => _cartItems;
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + (item.product.finalPrice * item.quantity));
  
  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }
  
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }
  
  void updateQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
      notifyListeners();
    }
  }
  
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

