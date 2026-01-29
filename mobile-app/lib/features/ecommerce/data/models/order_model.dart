class OrderItemModel {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final double total;
  final String? image;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
    this.image,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final productId = product is Map
        ? ((product['_id'] ?? product['id'])?.toString() ?? '')
        : (product?.toString() ?? '');
    return OrderItemModel(
      productId: productId,
      name: json['name'] ?? '',
      quantity: (json['quantity'] ?? 1).toInt(),
      price: (json['price'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      image: product is Map ? (product['image'] ?? product['images']?[0]) : null,
    );
  }
}

class ShippingAddressModel {
  final String name;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String pincode;

  ShippingAddressModel({
    required this.name,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    required this.pincode,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      addressLine1: json['addressLine1'] ?? json['address_line1'] ?? '',
      addressLine2: json['addressLine2'] ?? json['address_line2'],
      city: json['city'] ?? '',
      state: json['state'],
      pincode: json['pincode'] ?? json['pin_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final Map<String, dynamic>? user; // id, name, email, phoneNumber
  final List<OrderItemModel> items;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double total;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final ShippingAddressModel? shippingAddress;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    this.user,
    required this.items,
    required this.subtotal,
    this.shippingCost = 0,
    this.tax = 0,
    required this.total,
    required this.status,
    this.paymentStatus = 'pending',
    this.paymentMethod,
    this.shippingAddress,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? json['order_number'] ?? '',
      user: json['user'] is Map ? Map<String, dynamic>.from(json['user']) : null,
      items: itemsRaw.map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e))).toList(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingCost: (json['shippingCost'] ?? json['shipping_cost'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? json['payment_status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? json['payment_method'],
      shippingAddress: json['shippingAddress'] != null
          ? ShippingAddressModel.fromJson(Map<String, dynamic>.from(json['shippingAddress']))
          : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
