import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plant/core/constants/api_constants.dart';
import 'package:urban_plant/core/services/dio_client.dart';
import 'package:urban_plant/features/dashboard/presentation/providers/cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    final p = price.toInt();
    return p.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text('Ringkasan Pesanan'),
            ...cart.items.map((item) => Text(item.product?.name ?? '-')),
          ],
        ),
      ),
    );
  }
}
