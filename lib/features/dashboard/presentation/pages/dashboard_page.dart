import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_plant/core/routes/app_router.dart';
import 'package:urban_plant/features/auth/presentation/providers/auth_provider.dart';
import 'package:urban_plant/features/dashboard/data/models/product_model.dart';
import 'package:urban_plant/features/dashboard/presentation/providers/product_provider.dart';
import 'package:urban_plant/features/dashboard/presentation/pages/product_detail_page.dart';
import 'package:urban_plant/features/dashboard/presentation/providers/wishlist_provider.dart';
import 'package:urban_plant/features/dashboard/presentation/providers/cart_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final PageController _bannerController = PageController();
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Indoor',
    'Outdoor',
    'Sukulen',
    'Aksesori',
  ];

  final List<Map<String, String>> _banners = [
    {
      'title': 'Koleksi Monstera Terbaru',
      'subtitle': 'Percantik ruanganmu dengan tanaman tropis',
      'image':
          'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?w=800&q=80',
      'color': '1B5E20',
    },
    {
      'title': 'Promo Sukulen Cantik',
      'subtitle': 'Diskon 20% untuk semua sukulen',
      'image':
          'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=800&q=80',
      'color': '33691E',
    },
    {
      'title': 'Aksesori Tanaman',
      'subtitle': 'Pot & media tanam berkualitas premium',
      'image':
          'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=800&q=80',
      'color': '2E7D32',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<WishlistProvider>().fetchWishlist();
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
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
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage(AuthProvider auth, ProductProvider product) {
    final filtered = product.products.where((p) {
      final matchCategory =
          _selectedCategory == 'Semua' || p.category == _selectedCategory;
      final matchSearch =
          _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${auth.firebaseUser?.displayName?.split(' ').first ?? 'User'} 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const Text(
                          'Temukan tanaman favoritmu',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Cari tanaman...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Banner Slider
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _bannerController,
                itemCount: _banners.length,
                itemBuilder: (context, i) {
                  final banner = _banners[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(banner['image']!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Color(
                            int.parse('FF${banner['color']}', radix: 16),
                          ).withOpacity(0.6),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          banner['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner['subtitle']!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Kategori
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 0, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = _categories[i];
                        final isSelected = cat == _selectedCategory;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2E7D32)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Header produk
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filtered.length} Produk',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  Text(
                    _selectedCategory == 'Semua'
                        ? 'Semua Kategori'
                        : _selectedCategory,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ),

          // Grid Produk
          product.status == ProductStatus.loading ||
                  product.status == ProductStatus.initial
              ? const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                )
              : product.status == ProductStatus.error
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        Text(product.error ?? 'Terjadi kesalahan'),
                        TextButton(
                          onPressed: () => product.fetchProducts(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : filtered.isEmpty
              ? const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: Center(child: Text('Tidak ada produk ditemukan')),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildProductCard(filtered[i]),
                      childCount: filtered.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                  ),
                ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final p = price.toInt();
    final formatted = p.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return formatted;
  }

  Widget _buildProductCard(ProductModel p) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    p.imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 130,
                      color: Colors.grey.shade100,
                      child: const Icon(
                        Icons.local_florist,
                        size: 40,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () =>
                        context.read<WishlistProvider>().toggleWishlist(p),
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlist, _) => Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          wishlist.isWishlisted(p.id)
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          size: 16,
                          color: wishlist.isWishlisted(p.id)
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1B5E20),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      p.category,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < p.dummyRating.round()
                              ? Icons.star
                              : Icons.star_outline,
                          color: Colors.amber,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${p.dummyReviewCount})',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${_formatPrice(p.price)}',
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await context.read<CartProvider>().addToCart(p.id, 1);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${p.name} ditambahkan ke keranjang!',
                              ),
                              backgroundColor: const Color(0xFF2E7D32),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistPage() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Text(
                  'Wishlist',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<WishlistProvider>(
              builder: (context, wishlist, _) {
                if (wishlist.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  );
                }
                if (wishlist.wishlistProducts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_outline,
                          size: 80,
                          color: Color(0xFFE8F5E9),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Wishlist masih kosong',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tambahkan tanaman favoritmu!',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.58,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: wishlist.wishlistProducts.length,
                  itemBuilder: (context, i) =>
                      _buildProductCard(wishlist.wishlistProducts[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartPage() {
  return SafeArea(
    child: Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Keranjang',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  if (cart.items.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        await cart.clearCart();
                      },
                      child: const Text(
                        'Hapus Semua',
                        style: TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),

            // Loading
            if (cart.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                ),
              )

            // Empty state
            else if (cart.items.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 80, color: Color(0xFFE8F5E9)),
                      SizedBox(height: 16),
                      Text('Keranjang masih kosong',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20))),
                      SizedBox(height: 8),
                      Text('Yuk belanja tanaman dulu!',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
              )

            // List item cart
            else ...[
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, i) {
                    final item = cart.items[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Gambar produk
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item.product?.imageUrl ?? '',
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 70,
                                height: 70,
                                color: const Color(0xFFE8F5E9),
                                child: const Icon(Icons.local_florist, color: Color(0xFF2E7D32)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Info produk
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product?.name ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF1B5E20),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${_formatPrice(item.product?.price ?? 0)}',
                                  style: const TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Quantity control
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        if (item.quantity > 1) {
                                          await cart.updateQuantity(item.id, item.quantity - 1);
                                        } else {
                                          await cart.removeItem(item.id);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          item.quantity > 1 ? Icons.remove : Icons.delete_outline,
                                          size: 16,
                                          color: item.quantity > 1 ? const Color(0xFF2E7D32) : Colors.red,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await cart.updateQuantity(item.id, item.quantity + 1);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2E7D32),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Subtotal
                          Text(
                            'Rp ${_formatPrice(item.subtotal)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Total & Checkout button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2)),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(
                          'Rp ${_formatPrice(cart.totalPrice)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        Text(
                          '${cart.totalItems} item',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: navigate ke checkout page
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Checkout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    ),
  );
}

  Widget _buildProfilePage(AuthProvider auth) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE8F5E9),
                border: Border.all(color: const Color(0xFF2E7D32), width: 2),
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              auth.firebaseUser?.displayName ?? 'User',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            Text(
              auth.firebaseUser?.email ?? '',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            // Menu
            _buildProfileMenu(
              Icons.shopping_bag_outlined,
              'Pesanan Saya',
              () {},
            ),
            _buildProfileMenu(
              Icons.favorite_outline,
              'Wishlist',
              () => setState(() => _currentIndex = 1),
            ),
            _buildProfileMenu(Icons.location_on_outlined, 'Alamat', () {}),
            _buildProfileMenu(Icons.settings_outlined, 'Pengaturan', () {}),
            const SizedBox(height: 16),
            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Keluar',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await auth.logout();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, AppRouter.login);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
