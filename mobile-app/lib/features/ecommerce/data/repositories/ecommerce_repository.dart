import '../../../../core/services/api_service.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/shop_page_config_model.dart';

class EcommerceRepository {
  final ApiService _api = ApiService();

  /// GET /categories - list active categories
  Future<List<CategoryModel>> getCategories() async {
    final res = await _api.get('/categories');
    if (res['success'] != true) throw Exception(res['message'] ?? 'Failed to load categories');
    final data = res['data'];
    if (data is! List) return [];
    return (data).map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  /// GET /products - list products (public). [section] = bestsellers | family_pack | favourites for carousel sections.
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    String? section,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (section != null && section.isNotEmpty) params['section'] = section;
    final res = await _api.get('/products', queryParameters: params);
    if (res['success'] != true) throw Exception(res['message'] ?? 'Failed to load products');
    final list = res['data'] is List ? res['data'] as List : [];
    final pagination = res['pagination'] is Map ? res['pagination'] as Map<String, dynamic> : {};
    final products = list.map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList();
    return {'products': products, 'pagination': pagination};
  }

  /// GET /products/:id - get product by id (public)
  Future<Product> getProductById(String id) async {
    final res = await _api.get('/products/$id');
    if (res['success'] != true) throw Exception(res['message'] ?? 'Product not found');
    return Product.fromJson(Map<String, dynamic>.from(res['data']));
  }

  /// POST /orders - create order (auth required)
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items,
    required ShippingAddressModel shippingAddress,
    String paymentMethod = 'cod',
  }) async {
    final body = {
      'items': items,
      'shippingAddress': shippingAddress.toJson(),
      'paymentMethod': paymentMethod,
    };
    final res = await _api.post('/orders', data: body);
    if (res['success'] != true) throw Exception(res['message'] ?? 'Failed to place order');
    return OrderModel.fromJson(Map<String, dynamic>.from(res['data']));
  }

  /// GET /orders - list user orders (auth required)
  Future<Map<String, dynamic>> getOrders({int page = 1, int limit = 20, String? status}) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (status != null && status.isNotEmpty) params['status'] = status;
    final res = await _api.get('/orders', queryParameters: params);
    if (res['success'] != true) throw Exception(res['message'] ?? 'Failed to load orders');
    final list = res['data'] is List ? res['data'] as List : [];
    final pagination = res['pagination'] is Map ? res['pagination'] as Map<String, dynamic> : {};
    final orders = list.map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e))).toList();
    return {'orders': orders, 'pagination': pagination};
  }

  /// GET /orders/:id - get order by id (auth required)
  Future<OrderModel> getOrderById(String id) async {
    final res = await _api.get('/orders/$id');
    if (res['success'] != true) throw Exception(res['message'] ?? 'Order not found');
    return OrderModel.fromJson(Map<String, dynamic>.from(res['data']));
  }

  /// PUT /orders/:id/cancel - cancel order (auth required)
  Future<void> cancelOrder(String id) async {
    final res = await _api.put('/orders/$id/cancel', data: {});
    if (res['success'] != true) throw Exception(res['message'] ?? 'Failed to cancel order');
  }

  /// GET /shop-config - get shop page config (public, for mobile app sections)
  Future<ShopPageConfigModel> getShopConfig() async {
    final res = await _api.get('/shop-config');
    if (res['success'] != true) throw Exception(res['message'] ?? 'Failed to load shop config');
    return ShopPageConfigModel.fromJson(Map<String, dynamic>.from(res['data']));
  }
}
