import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:urban_plant/core/constants/api_constants.dart';
import 'package:urban_plant/core/services/dio_client.dart';

class PaymentCallbackData {
  final String status;
  final String? reference;
  final String? transactionId;

  const PaymentCallbackData({
    required this.status,
    this.reference,
    this.transactionId,
  });

  bool get isSuccess => status == 'success';
}

class PaymentDeeplinkService {
  static final PaymentDeeplinkService _instance = PaymentDeeplinkService._();
  factory PaymentDeeplinkService() => _instance;
  PaymentDeeplinkService._();

  final _callbackController = StreamController<PaymentCallbackData>.broadcast();
  Stream<PaymentCallbackData> get onCallback => _callbackController.stream;

  Future<void> init() async {
    final appLinks = AppLinks();

    // Cold start
    try {
      final uri = await appLinks.getInitialLink();
      if (uri != null) _handleUri(uri);
    } catch (e) {
      debugPrint('[PaymentDeeplinkService] getInitialLink error: $e');
    }

    // In-app
    appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (e) => debugPrint('[PaymentDeeplinkService] stream error: $e'),
    );
  }

  void _handleUri(Uri uri) {
    debugPrint('[PaymentDeeplinkService] URI masuk: $uri');
    debugPrint(
      '[PaymentDeeplinkService] scheme: ${uri.scheme}, host: ${uri.host}',
    );

    if (uri.scheme != 'urbanplant' || uri.host != 'payment-callback') {
      debugPrint('[PaymentDeeplinkService] URI tidak cocok, diabaikan');
      return;
    }

    final data = PaymentCallbackData(
      status: uri.queryParameters['status'] ?? 'unknown',
      reference: uri.queryParameters['reference'],
      transactionId: uri.queryParameters['transaction_id'],
    );

    debugPrint('[PaymentDeeplinkService] Sebelum add ke stream');
    _callbackController.add(data);
    debugPrint('[PaymentDeeplinkService] Sesudah add ke stream');
    debugPrint(
      '[PaymentDeeplinkService] hasListener: ${_callbackController.hasListener}',
    );
  }

  /// Update payment status ke backend urban_plant
  Future<void> updatePaymentStatus(int orderId) async {
    try {
      await DioClient.instance.put(
        '${ApiConstants.orders}/$orderId/payment',
        data: {'payment_status': 'paid'},
      );
      debugPrint(
        '[PaymentDeeplinkService] Payment status updated untuk order #$orderId',
      );
    } catch (e) {
      debugPrint('[PaymentDeeplinkService] Gagal update payment status: $e');
    }
  }

  /// Build URL deeplink ke dompet_kampus_global
  static String buildPaymentUrl({
    required int orderId,
    required double amount,
    String? description,
  }) {
    final uri = Uri(
      scheme: 'dompetkampus',
      host: 'pay',
      queryParameters: {
        'merchant_id': 'MCH_URBAN_PLANT',
        'merchant_name': 'Urban Plant',
        'amount': amount.toInt().toString(),
        'description': description ?? 'Order #$orderId',
        'reference': 'INV-$orderId',
        'callback': 'urbanplant://payment-callback',
      },
    );
    return uri.toString();
  }
}
