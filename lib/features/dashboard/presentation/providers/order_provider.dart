import 'package:flutter/material.dart';
import 'package:urban_plant/core/constants/api_constants.dart';
import 'package:urban_plant/core/services/dio_client.dart';
import 'package:urban_plant/features/dashboard/data/models/order_model.dart';

enum OrderStatus { initial, loading, loaded, error }

class OrderProvider extends ChangeNotifier {
  OrderStatus _status = OrderStatus.initial;
  List<OrderModel> _orders = [];
  String? _error;

  OrderStatus get status => _status;
  List<OrderModel> get orders => _orders;
  String? get error => _error;
  bool get isLoading => _status == OrderStatus.loading;

  Future<void> fetchOrders() async {
    _status = OrderStatus.loading;
    notifyListeners();
    try {
      final response = await DioClient.instance.get(ApiConstants.orders);
      final List<dynamic> data = response.data['data'] ?? [];
      _orders = data.map((e) => OrderModel.fromJson(e)).toList();
      _status = OrderStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = OrderStatus.error;
    }
    notifyListeners();
  }
}