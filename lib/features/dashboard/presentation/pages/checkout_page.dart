import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plant/core/constants/api_constants.dart';
import 'package:urban_plant/core/services/dio_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:urban_plant/core/services/payment_deeplink_service.dart';
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
  String _paymentMethod = 'transfer';
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

    if (_paymentMethod == 'dompet_kampus') {
      await _payWithDompetKampus();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await DioClient.instance.post(
        ApiConstants.checkout,
        data: {
          'shipping_address': _addressCtrl.text.trim(),
          'notes': _notesCtrl.text.trim().isEmpty
              ? '[Pembayaran: ${_paymentMethod == 'cod' ? 'COD' : 'Transfer Bank'}]'
              : '${_notesCtrl.text.trim()} | [Pembayaran: ${_paymentMethod == 'cod' ? 'COD' : 'Transfer Bank'}]',
        },
      );

      if (!mounted) return;

      if (response.data['success'] == true) {
        final order = response.data['data'];
        await context.read<CartProvider>().fetchCart();
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OrderSuccessPage(order: order)),
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

  Future<void> _payWithDompetKampus() async {
    final cart = context.read<CartProvider>();
    setState(() => _isLoading = true);
    try {
      final response = await DioClient.instance.post(
        ApiConstants.checkout,
        data: {
          'shipping_address': _addressCtrl.text.trim().isEmpty
              ? 'Alamat belum diisi'
              : _addressCtrl.text.trim(),
          'notes': 'Pembayaran via Dompet Kampus Global',
        },
      );

      if (response.data['success'] == true) {
        final order = response.data['data'];
        final orderId = order['ID'] ?? order['id'] ?? 0;
        final totalAmount =
            (order['total_amount'] as num?)?.toDouble() ?? cart.totalPrice;

        final url = PaymentDeeplinkService.buildPaymentUrl(
          orderId: orderId,
          amount: totalAmount,
          description: 'Pembayaran Urban Plant #$orderId',
        );

        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ringkasan pesanan ──────────────────────────────
              const Text(
                'Ringkasan Pesanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ...cart.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product?.imageUrl ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 50,
                                  height: 50,
                                  color: const Color(0xFFE8F5E9),
                                  child: const Icon(
                                    Icons.local_florist,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product?.name ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${item.quantity}x Rp ${_formatPrice(item.product?.price ?? 0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Rp ${_formatPrice(item.subtotal)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total (${cart.totalItems} item)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Rp ${_formatPrice(cart.totalPrice)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Alamat pengiriman ──────────────────────────────
              const Text(
                'Alamat Pengiriman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan alamat lengkap...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, top: 12),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Alamat wajib diisi' : null,
              ),

              const SizedBox(height: 16),

              // ── Catatan ────────────────────────────────────────
              const Text(
                'Catatan (opsional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Tambahkan catatan untuk penjual...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, top: 12),
                    child: Icon(Icons.note_outlined, color: Color(0xFF2E7D32)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Metode pembayaran ──────────────────────────────
              const Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      value: 'transfer',
                      groupValue: _paymentMethod,
                      onChanged: (v) => setState(() => _paymentMethod = v!),
                      activeColor: const Color(0xFF2E7D32),
                      title: const Row(
                        children: [
                          Icon(Icons.account_balance_outlined,
                              color: Color(0xFF2E7D32), size: 20),
                          SizedBox(width: 8),
                          Text('Transfer Bank',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                      subtitle: const Text('BCA, BNI, BRI, Mandiri',
                          style: TextStyle(fontSize: 12)),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      value: 'cod',
                      groupValue: _paymentMethod,
                      onChanged: (v) => setState(() => _paymentMethod = v!),
                      activeColor: const Color(0xFF2E7D32),
                      title: const Row(
                        children: [
                          Icon(Icons.delivery_dining_outlined,
                              color: Color(0xFF2E7D32), size: 20),
                          SizedBox(width: 8),
                          Text('COD (Bayar di Tempat)',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                      subtitle: const Text('Bayar ketika pesanan sudah sampai',
                          style: TextStyle(fontSize: 12)),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      value: 'dompet_kampus',
                      groupValue: _paymentMethod,
                      onChanged: (v) => setState(() => _paymentMethod = v!),
                      activeColor: const Color(0xFF2E7D32),
                      title: const Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              color: Color(0xFF2E7D32), size: 20),
                          SizedBox(width: 8),
                          Text('Dompet Kampus Global',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                        ],
                      ),
                      subtitle: const Text('Bayar langsung via e-money',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),

              // Info COD
              if (_paymentMethod == 'cod') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Color(0xFFF57F17), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bayar nanti ya ketika pesanan sudah sampai di tanganmu! 🌿',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFFF57F17)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Info Transfer Bank
              if (_paymentMethod == 'transfer') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Color(0xFF2E7D32), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Info Transfer Bank',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32)),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('BCA  : 1234567890 (Urban Plant)',
                          style: TextStyle(fontSize: 12)),
                      Text('BNI  : 0987654321 (Urban Plant)',
                          style: TextStyle(fontSize: 12)),
                      Text('BRI  : 1122334455 (Urban Plant)',
                          style: TextStyle(fontSize: 12)),
                      SizedBox(height: 4),
                      Text('*Transfer sesuai total pesanan',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],

              // Info Dompet Kampus
              if (_paymentMethod == 'dompet_kampus') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA5D6A7)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Color(0xFF2E7D32), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Kamu akan diarahkan ke Dompet Kampus Global untuk menyelesaikan pembayaran.',
                          style: TextStyle(
                              fontSize: 12, color: Color(0xFF2E7D32)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ── Tombol checkout ────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Pesan Sekarang • Rp ${_formatPrice(cart.totalPrice)}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
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
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    size: 60, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pesanan Berhasil! 🌿',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pesanan #${order['ID'] ?? order['id'] ?? '-'} sedang diproses',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Status', 'Pending'),
                    const Divider(height: 20),
                    _buildDetailRow(
                      'Total',
                      'Rp ${_formatPrice((order['total_amount'] as num?)?.toDouble() ?? 0)}',
                    ),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Lihat Pesanan Saya',
                  style: TextStyle(color: Color(0xFF2E7D32)),
                ),
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
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}