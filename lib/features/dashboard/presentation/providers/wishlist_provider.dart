import 'package:flutter/material.dart';
import 'package:urban_plant/core/constants/api_constants.dart';
import 'package:urban_plant/core/services/dio_client.dart';
import 'package:urban_plant/features/dashboard/data/models/product_model.dart';

enum WishlistStatus { initial, loading, loaded, error }

class WishlistProvider extends ChangeNotifier {
  WishlistStatus _status = WishlistStatus.initial;
  List<ProductModel> _wishlistProducts = [];
  Set<int> _wishlistIds = {};
  String? _error;

  WishlistStatus get status => _status;
  List<ProductModel> get wishlistProducts => _wishlistProducts;
  Set<int> get wishlistIds => _wishlistIds;
  String? get error => _error;
  bool get isLoading => _status == WishlistStatus.loading;

  bool isWishlisted(int productId) => _wishlistIds.contains(productId);

  Future<void> fetchWishlist() async {
    _status = WishlistStatus.loading;
    notifyListeners();
    try {
      final response = await DioClient.instance.get(ApiConstants.wishlist);
      final List<dynamic> data = response.data['data'] ?? [];
      _wishlistProducts = data.map((item) {
        final productJson = item['product'] as Map<String, dynamic>;
        return ProductModel.fromJson(productJson);
      }).toList();
      _wishlistIds = _wishlistProducts.map((p) => p.id).toSet();
      _status = WishlistStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = WishlistStatus.error;
    }
    notifyListeners();
  }

  Future<void> toggleWishlist(ProductModel product) async {
    final isAlreadyWishlisted = _wishlistIds.contains(product.id);
    try {
      if (isAlreadyWishlisted) {
        await DioClient.instance.delete('${ApiConstants.wishlist}/${product.id}');
        _wishlistIds.remove(product.id);
        _wishlistProducts.removeWhere((p) => p.id == product.id);
      } else {
        await DioClient.instance.post(
          ApiConstants.wishlist,
          data: {'product_id': product.id},
        );
        _wishlistIds.add(product.id);
        _wishlistProducts.add(product);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggleWishlist: $e');
    }
  }
}