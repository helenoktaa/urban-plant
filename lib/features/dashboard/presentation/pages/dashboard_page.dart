import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plant/core/routes/app_router.dart';
import 'package:urban_plant/features/auth/presentation/providers/auth_provider.dart';
import 'package:urban_plant/features/dashboard/data/models/product_model.dart';
import 'package:urban_plant/features/dashboard/presentation/providers/product_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final product = context.watch<ProductProvider>();

    final pages = [
      _buildHomePage(auth, product),
      _buildWishlistPage(),
      _buildCartPage(),
      _buildProfilePage(auth),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: pages[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), activeIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }

  Widget _buildHomePage(AuthProvider auth, ProductProvider product) {
    return const Center(child: Text('Home Page'));
  }

  Widget _buildWishlistPage() {
    return const Center(child: Text('Wishlist'));
  }

  Widget _buildCartPage() {
    return const Center(child: Text('Cart'));
  }

  Widget _buildProfilePage(AuthProvider auth) {
    return const Center(child: Text('Profile'));
  }
}