import 'package:urban_plant/features/dashboard/data/models/product_model.dart';

class CartItemModel {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final ProductModel? product;

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
  id: (json['ID'] as num?)?.toInt() ?? (json['id'] as num?)?.toInt() ?? 0,
  userId: (json['user_id'] as num?)?.toInt() ?? 0,
  productId: (json['product_id'] as num?)?.toInt() ?? 0,
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  product: json['product'] != null
      ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
      : null,
);

  double get subtotal => (product?.price ?? 0) * quantity;
}