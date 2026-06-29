import 'package:flutter/material.dart';

class OrderItemModel {
  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    id: (json['id'] as num?)?.toInt() ?? 0,
    orderId: (json['order_id'] as num?)?.toInt() ?? 0,
    productId: (json['product_id'] as num?)?.toInt() ?? 0,
    productName: json['product_name'] as String? ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
  );
}

class OrderModel {
  final int id;
  final int userId;
  final String status;
  final String paymentStatus;
   final String paymentMethod; 
  final String? paidAt;
  final double totalAmount;
  final String shippingAddress;
  final String notes;
  final String createdAt;
  final List<OrderItemModel> items;

  bool get isPaid => paymentStatus == 'paid';

  String get paymentMethodLabel => switch (paymentMethod) {
    'transfer'      => 'Transfer Bank',
    'cod'           => 'COD (Bayar di Tempat)',
    'dompet_kampus' => 'Wallt',
    _               => paymentMethod,
  };

  IconData get paymentMethodIcon => switch (paymentMethod) {
    'transfer'      => Icons.account_balance_outlined,
    'cod'           => Icons.delivery_dining_outlined,
    'dompet_kampus' => Icons.account_balance_wallet_outlined,
    _               => Icons.payment,
  };

  OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    required this.paymentStatus,
     required this.paymentMethod,
    this.paidAt,
    required this.totalAmount,
    required this.shippingAddress,
    required this.notes,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: (json['id'] as num?)?.toInt() ?? 0,
    userId: (json['user_id'] as num?)?.toInt() ?? 0,
    status: json['status'] as String? ?? 'pending',
    paymentStatus: json['payment_status'] ?? 'unpaid',
    paymentMethod:   json['payment_method'] ?? 'transfer', 
    paidAt: json['paid_at'],
    totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    shippingAddress: json['shipping_address'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    createdAt: json['created_at'] as String? ?? '',
    items: (json['items'] as List<dynamic>? ?? [])
        .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  String get statusLabel => switch (status) {
    'pending' => 'Menunggu',
    'processing' => 'Diproses',
    'shipped' => 'Dikirim',
    'delivered' => 'Selesai',
    'cancelled' => 'Dibatalkan',
    _ => status,
  };

  Color get statusColor => switch (status) {
    'pending' => const Color(0xFFF57F17),
    'processing' => const Color(0xFF1565C0),
    'shipped' => const Color(0xFF6A1B9A),
    'delivered' => const Color(0xFF2E7D32),
    'cancelled' => const Color(0xFFC62828),
    _ => Colors.grey,
  };
}
