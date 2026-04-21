import 'package:flutter/material.dart';
import 'package:urban_plant/core/constants/api_constants.dart';
import 'package:urban_plant/core/services/dio_client.dart';
import 'package:urban_plant/features/dashboard/data/models/cart_model.dart';

enum CartStatus { initial, loading, loaded, error }

class CartProvider extends ChangeNotifier {
  CartStatus _status = CartStatus.initial;
  List<CartItemModel> _items = [];
  String? _error;

  CartStatus get status => _status;
  List<CartItemModel> get items => _items;
  String? get error => _error;
  bool get isLoading => _status == CartStatus.loading;

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.subtotal);

  int get totalItems =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> fetchCart() async {
    _status = CartStatus.loading;
    notifyListeners();
    try {
      final response = await DioClient.instance.get(ApiConstants.cart);
      final List<dynamic> data = response.data['data'] ?? [];
      _items = data.map((e) => CartItemModel.fromJson(e)).toList();
      _status = CartStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = CartStatus.error;
    }
    notifyListeners();
  }

  Future<void> addToCart(int productId, int quantity) async {
    try {
      await DioClient.instance.post(
        ApiConstants.cart,
        data: {'product_id': productId, 'quantity': quantity},
      );
      await fetchCart();
    } catch (e) {
      debugPrint('Error addToCart: $e');
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    try {
      await DioClient.instance.put(
        '${ApiConstants.cart}/$cartItemId',
        data: {'quantity': quantity},
      );
      await fetchCart();
    } catch (e) {
      debugPrint('Error updateQuantity: $e');
    }
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      await DioClient.instance.delete('${ApiConstants.cart}/$cartItemId');
      await fetchCart();
    } catch (e) {
      debugPrint('Error removeItem: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await DioClient.instance.delete(ApiConstants.cart);
      _items = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearCart: $e');
    }
  }
}