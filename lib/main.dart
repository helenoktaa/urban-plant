import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plant/core/routes/app_router.dart';
import 'package:urban_plant/features/auth/presentation/providers/auth_provider.dart';
import 'package:urban_plant/features/dashboard/presentation/providers/product_provider.dart';
import 'package:urban_plant/features/dashboard/presentation/providers/wishlist_provider.dart';
import 'package:urban_plant/features/dashboard/presentation/providers/cart_provider.dart';
import 'package:urban_plant/features/dashboard/presentation/providers/order_provider.dart';
import 'package:urban_plant/core/providers/theme_provider.dart';
import 'package:urban_plant/core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase SEBELUM runApp
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final themeProvider = ThemeProvider();

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
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      themeMode: themeProvider.themeMode,

      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
    );
  }
}
