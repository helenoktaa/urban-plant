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

  Future<void> _checkout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final response = await DioClient.instance.post(
        ApiConstants.checkout,
        data: {
          'shipping_address': _addressCtrl.text.trim(),
          'notes': _notesCtrl.text.trim(),
        },
      );

      if (!mounted) return;

      if (response.data['success'] == true) {
        final order = response.data['data'];
        await context.read<CartProvider>().fetchCart();
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessPage(order: order),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout gagal: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ringkasan pesanan
              const Text('Ringkasan Pesanan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    ...cart.items.map((item) => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.product?.imageUrl ?? '',
                              width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 50, height: 50,
                                color: const Color(0xFFE8F5E9),
                                child: const Icon(Icons.local_florist, color: Color(0xFF2E7D32)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product?.name ?? '-',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('${item.quantity}x Rp ${_formatPrice(item.product?.price ?? 0)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                          Text('Rp ${_formatPrice(item.subtotal)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 13)),
                        ],
                      ),
                    )),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total (${cart.totalItems} item)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Rp ${_formatPrice(cart.totalPrice)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Alamat pengiriman
              const Text('Alamat Pengiriman',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan alamat lengkap...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, top: 12),
                    child: Icon(Icons.location_on_outlined, color: Color(0xFF2E7D32)),
                  ),
                ),
                validator: (v) => (v?.isEmpty ?? true) ? 'Alamat wajib diisi' : null,
              ),

              const SizedBox(height: 16),

              // Catatan
              const Text('Catatan (opsional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Tambahkan catatan untuk penjual...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, top: 12),
                    child: Icon(Icons.note_outlined, color: Color(0xFF2E7D32)),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Tombol checkout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Pesan Sekarang • Rp ${_formatPrice(cart.totalPrice)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Order Success Page ───────────────────────────────────────────────────────
class OrderSuccessPage extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderSuccessPage({super.key, required this.order});

  String _formatPrice(double price) {
    final p = price.toInt();
    return p.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon sukses
              Container(
                width: 100, height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 60, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 24),
              const Text('Pesanan Berhasil! 🌿',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
              const SizedBox(height: 8),
              Text('Pesanan #${order['ID'] ?? order['id'] ?? '-'} sedang diproses',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 32),

              // Detail order
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Status', 'Pending'),
                    const Divider(height: 20),
                    _buildDetailRow('Total',
                      'Rp ${_formatPrice((order['total_amount'] as num?)?.toDouble() ?? 0)}'),
                    const Divider(height: 20),
                    _buildDetailRow('Alamat', order['shipping_address'] ?? '-'),
                    if ((order['notes'] ?? '').toString().isNotEmpty) ...[
                      const Divider(height: 20),
                      _buildDetailRow('Catatan', order['notes']),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Tombol kembali
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kembali ke Beranda', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Lihat Pesanan Saya', style: TextStyle(color: Color(0xFF2E7D32))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 80,
          child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500))),
        const SizedBox(width: 12),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
      ],
    );
  }
}