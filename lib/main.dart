import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plant/core/services/payment_deeplink_service.dart';
import 'package:urban_plant/core/routes/app_router.dart';
import 'package:urban_plant/features/auth/presentation/providers/auth_provider.dart';
import 'package:urban_plant/features/dashboard/presentation/providers/product_provider.dart';
import 'package:urban_plant/features/dashboard/presentation/providers/wishlist_provider.dart';
import 'package:urban_plant/features/dashboard/presentation/providers/cart_provider.dart';
import 'package:urban_plant/features/dashboard/presentation/providers/order_provider.dart';
import 'package:urban_plant/core/providers/theme_provider.dart';
import 'package:urban_plant/core/theme/app_theme.dart';
import 'firebase_options.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final deeplinkService = PaymentDeeplinkService();
  await deeplinkService.init();

  deeplinkService.onCallback.listen((data) async {
    debugPrint('[Main] Callback diterima: status=${data.status}, ref=${data.reference}');

    if (!data.isSuccess) {
      debugPrint('[Main] Status bukan success, diabaikan');
      return;
    }

    final ref = data.reference ?? '';
    debugPrint('[Main] Reference: $ref');

    final orderId = int.tryParse(ref.replaceFirst('INV-', ''));
    debugPrint('[Main] OrderId parsed: $orderId');

    if (orderId == null) {
      debugPrint('[Main] Reference tidak valid: $ref');
      return;
    }

    await deeplinkService.updatePaymentStatus(orderId);
    debugPrint('[Main] Payment berhasil diupdate untuk order #$orderId');

    await Future.delayed(const Duration(milliseconds: 500));

    debugPrint('ScaffoldKey mounted: ${scaffoldMessengerKey.currentState != null}');

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text('Pembayaran berhasil! Pesanan sedang diproses.'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
    );
  }
}