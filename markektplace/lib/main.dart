import 'package:flutter/material.dart';

import 'login.dart' as login;

void main() => runApp(const MyApp());

// Palet Warna Khas FamilyMart
const Color fmGreen = Color(0xFF009944);
const Color fmBlue = Color(0xFF0080C6);
const Color ink = Color(0xFF192C28);
const Color paper = Color(0xFFF5F8FA);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FamilyMart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: fmGreen,
          primary: fmGreen,
          secondary: fmBlue,
        ),
      ),
      home: const StorePage(),
    );
  }
}

// Model disesuaikan dengan struktur tabel `produk` & `kategori` di db_marketplace.sql
class StoreProduct {
  const StoreProduct({
    required this.idProduk,
    required this.idKategori,
    required this.namaProduk,
    required this.namaKategori,
    required this.harga,
    required this.stok,
    required this.foto,
    this.badge,
  });

  final int idProduk;
  final int idKategori;
  final String namaProduk;
  final String namaKategori;
  final int harga;
  final int stok;
  final String foto;
  final String? badge;
}

const List<StoreProduct> products = [
  StoreProduct(
    idProduk: 1,
    idKategori: 1,
    namaProduk: 'Kopi Susu Keluarga (KSK)',
    namaKategori: 'FamiCafé',
    harga: 18000,
    stok: 50,
    badge: 'Terlaris',
    foto: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=700&auto=format&fit=crop&q=85',
  ),
  StoreProduct(
    idProduk: 2,
    idKategori: 2,
    namaProduk: 'Onigiri Tuna Mayo',
    namaKategori: 'Siap Saji',
    harga: 14000,
    stok: 30,
    badge: 'Fresh',
    foto: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=700&auto=format&fit=crop&q=85',
  ),
  StoreProduct(
    idProduk: 3,
    idKategori: 2,
    namaProduk: 'Crispy Chicken Nugget Bowl',
    namaKategori: 'Siap Saji',
    harga: 22000,
    stok: 25,
    badge: 'Favorit',
    foto: 'https://images.unsplash.com/photo-1562967914-608f82629710?w=700&auto=format&fit=crop&q=85',
  ),
  StoreProduct(
    idProduk: 4,
    idKategori: 1,
    namaProduk: 'Iced Matcha Latte',
    namaKategori: 'FamiCafé',
    harga: 20000,
    stok: 40,
    foto: 'https://images.unsplash.com/photo-1515823064-d6e0c04616a7?w=700&auto=format&fit=crop&q=85',
  ),
  StoreProduct(
    idProduk: 5,
    idKategori: 3,
    namaProduk: 'Oden Kuah Tomyum',
    namaKategori: 'Oden & Snack',
    harga: 19000,
    stok: 20,
    badge: 'Hangat',
    foto: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=700&auto=format&fit=crop&q=85',
  ),
  StoreProduct(
    idProduk: 6,
    idKategori: 4,
    namaProduk: 'Air Mineral 600ml',
    namaKategori: 'Minuman',
    harga: 5000,
    stok: 100,
    foto: 'https://images.unsplash.com/photo-1560023907-5f339617ea30?w=700&auto=format&fit=crop&q=85',
  ),
];

const List<String> categories = [
  'Semua',
  'FamiCafé',
  'Siap Saji',
  'Oden & Snack',
  'Minuman',
];

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => StorePageState();
}

class StorePageState extends State<StorePage> {
  int _selectedTab = 0;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final Map<int, int> _cart = {}; // Menggunakan idProduk sebagai key

  List<StoreProduct> get _visibleProducts => products.where((product) {
    final matchesCategory =
        _selectedCategory == 'Semua' ||
        product.namaKategori == _selectedCategory;
    final query = _searchQuery.trim().toLowerCase();
    return matchesCategory &&
        (product.namaProduk.toLowerCase().contains(query) ||
            product.namaKategori.toLowerCase().contains(query));
  }).toList();

  int get _cartCount => _cart.values.fold(0, (sum, amount) => sum + amount);

  void _addToCart(StoreProduct product) {
    final currentQty = _cart[product.idProduk] ?? 0;
    if (currentQty >= product.stok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Stok produk tidak mencukupi'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    setState(
      () => _cart.update(
        product.idProduk,
        (amount) => amount + 1,
        ifAbsent: () => 1,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.namaProduk} masuk ke keranjang'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _changeCartAmount(StoreProduct product, int change) {
    setState(() {
      final nextAmount = (_cart[product.idProduk] ?? 0) + change;
      if (nextAmount <= 0) {
        _cart.remove(product.idProduk);
      } else if (nextAmount <= product.stok) {
        _cart[product.idProduk] = nextAmount;
      }
    });
  }

  Future<void> _openAdminLogin() async {
    final loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const login.LoginPage()),
    );
    if (!mounted || loggedIn != true) return;
    setState(() => _selectedTab = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: [
            _buildHome(),
            _buildCatalog(),
            _buildCart(),
            _buildAccount(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        backgroundColor: Colors.white,
        indicatorColor: fmGreen.withValues(alpha: 0.15),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: fmGreen),
            label: 'Beranda',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view, color: fmGreen),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: _cartIcon(),
            selectedIcon: _cartIcon(selected: true),
            label: 'Keranjang',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: fmGreen),
            label: 'Akun',
          ),
        ],
      ),
    );
  }

  Widget _cartIcon({bool selected = false}) => Stack(
    clipBehavior: Clip.none,
    children: [
      Icon(
        selected ? Icons.shopping_bag : Icons.shopping_bag_outlined,
        color: selected ? fmGreen : null,
      ),
      if (_cartCount > 0)
        Positioned(
          right: -6,
          top: -6,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: fmBlue,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              '$_cartCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
    ],
  );

  Widget _buildHome() => CustomScrollView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        sliver: SliverToBoxAdapter(child: _buildHeader()),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
        sliver: SliverToBoxAdapter(child: _buildSearch()),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
        sliver: SliverToBoxAdapter(
          child: _sectionHeading(
            'Kategori Pilihan',
            'Lihat semua',
            () => setState(() => _selectedTab = 1),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.only(top: 14),
        sliver: SliverToBoxAdapter(child: _buildCategories()),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
        sliver: SliverToBoxAdapter(
          child: _sectionHeading(
            'Menu & Produk Favorit',
            'Lihat semua',
            () => setState(() => _selectedTab = 1),
          ),
        ),
      ),
      _productGrid(_visibleProducts.take(4).toList()),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ],
  );

  Widget _buildHeader() => Row(
    children: [
      Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [fmGreen, fmBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.local_convenience_store_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                children: [
                  TextSpan(
                    text: 'Family',
                    style: TextStyle(color: fmBlue),
                  ),
                  TextSpan(
                    text: 'Mart',
                    style: TextStyle(color: fmGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Segar & praktis setiap hari',
              style: TextStyle(color: Color(0xFF6B7774), fontSize: 12),
            ),
          ],
        ),
      ),
      IconButton(
        key: const Key('admin-login-entry-button'),
        tooltip: 'Masuk Admin',
        onPressed: _openAdminLogin,
        icon: const Icon(Icons.admin_panel_settings_outlined),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: fmGreen,
          fixedSize: const Size(46, 46),
        ),
      ),
      IconButton(
        tooltip: 'Keranjang',
        onPressed: () => setState(() => _selectedTab = 2),
        icon: _cartIcon(),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: ink,
          fixedSize: const Size(46, 46),
        ),
      ),
    ],
  );

  Widget _buildSearch() => TextField(
    onChanged: (value) => setState(() => _searchQuery = value),
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      hintText: 'Cari Kopi Susu Keluarga, Onigiri...',
      hintStyle: const TextStyle(color: Color(0xFF929A96), fontSize: 13),
      prefixIcon: const Icon(Icons.search_rounded, color: fmGreen),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _sectionHeading(String title, String action, VoidCallback onTap) =>
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: ink,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 32),
            ),
            child: Text(
              action,
              style: const TextStyle(
                color: fmBlue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );

  Widget _buildCategories() => SizedBox(
    height: 92,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      itemCount: categories.length - 1,
      separatorBuilder: (context, index) => const SizedBox(width: 15),
      itemBuilder: (context, index) {
        final category = categories[index + 1];
        return GestureDetector(
          onTap: () => setState(() {
            _selectedCategory = category;
            _selectedTab = 1;
          }),
          child: SizedBox(
            width: 72,
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? fmGreen.withValues(alpha: 0.12)
                        : fmBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _categoryIcon(category),
                    color: index % 2 == 0 ? fmGreen : fmBlue,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'FamiCafé':
        return Icons.coffee_rounded;
      case 'Siap Saji':
        return Icons.rice_bowl_rounded;
      case 'Oden & Snack':
        return Icons.ramen_dining_rounded;
      default:
        return Icons.local_drink_rounded;
    }
  }

  Widget _buildCatalog() => CustomScrollView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Katalog FamilyMart',
                style: TextStyle(
                  color: ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih menu favorit dan kebutuhan harianmu.',
                style: TextStyle(color: Color(0xFF77817D), fontSize: 13),
              ),
              const SizedBox(height: 18),
              _buildSearch(),
              const SizedBox(height: 16),
              _buildCategoryChips(),
              const SizedBox(height: 16),
              Text(
                '${_visibleProducts.length} produk tersedia',
                style: const TextStyle(
                  color: Color(0xFF77817D),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      _productGrid(_visibleProducts),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ],
  );

  Widget _buildCategoryChips() => SizedBox(
    height: 38,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final category = categories[index];
        final selected = _selectedCategory == category;
        return ChoiceChip(
          label: Text(category),
          selected: selected,
          onSelected: (value) => setState(() => _selectedCategory = category),
          labelStyle: TextStyle(
            color: selected ? Colors.white : ink,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.white,
          selectedColor: fmGreen,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        );
      },
    ),
  );

  Widget _productGrid(List<StoreProduct> items) {
    if (items.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(36),
        sliver: SliverToBoxAdapter(
          child: Column(
            children: const [
              Icon(Icons.search_off_rounded, size: 42, color: fmGreen),
              SizedBox(height: 10),
              Text(
                'Produk tidak ditemukan',
                style: TextStyle(color: ink, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Coba kata kunci atau kategori lain.',
                style: TextStyle(color: Color(0xFF77817D), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _productCard(items[index]),
          childCount: items.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 13,
          mainAxisSpacing: 13,
          mainAxisExtent: 255,
        ),
      ),
    );
  }

  Widget _productCard(StoreProduct product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  product.foto,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE9EEE8),
                    child: const Icon(
                      Icons.image_outlined,
                      size: 38,
                      color: fmGreen,
                    ),
                  ),
                ),
                if (product.badge != null)
                  Positioned(
                    top: 9,
                    left: 9,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: fmBlue,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 9, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.namaKategori.toUpperCase(),
                      style: const TextStyle(
                        color: fmBlue,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Stok: ${product.stok}',
                      style: const TextStyle(
                        color: Color(0xFF88948F),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.namaProduk,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatPrice(product.harga),
                        maxLines: 1,
                        style: const TextStyle(
                          color: fmGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => _addToCart(product),
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        width: 29,
                        height: 29,
                        decoration: BoxDecoration(
                          color: fmGreen,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 19,
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
    );
  }

  Widget _buildCart() {
    final cartProducts = products
        .where((product) => (_cart[product.idProduk] ?? 0) > 0)
        .toList();
    final total = cartProducts.fold<int>(
      0,
      (sum, product) => sum + (product.harga * (_cart[product.idProduk] ?? 0)),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Keranjang Belanja',
                  style: TextStyle(
                    color: ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$_cartCount item',
                style: const TextStyle(color: Color(0xFF77817D), fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: cartProducts.isEmpty
              ? _emptyCart()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  itemCount: cartProducts.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = cartProducts[index];
                    final quantity = _cart[product.idProduk] ?? 0;
                    return Container(
                      height: 100,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              product.foto,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 80,
                                    height: 80,
                                    color: const Color(0xFFE9EEE8),
                                    child: const Icon(
                                      Icons.image_outlined,
                                      color: fmGreen,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product.namaKategori,
                                  style: const TextStyle(
                                    color: fmBlue,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  product.namaProduk,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  _formatPrice(product.harga),
                                  style: const TextStyle(
                                    color: fmGreen,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          _quantityControl(
                            quantity,
                            () => _changeCartAmount(product, -1),
                            () => _changeCartAmount(product, 1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        if (cartProducts.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE8EBE7))),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            color: Color(0xFF68716D),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        _formatPrice(total),
                        style: const TextStyle(
                          color: ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _checkout,
                      icon: const Icon(Icons.receipt_long_rounded, size: 18),
                      label: const Text('Checkout Transaksi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: fmGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _quantityControl(
    int quantity,
    VoidCallback onMinus,
    VoidCallback onPlus,
  ) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _quantityButton(Icons.remove, onMinus),
      SizedBox(
        width: 25,
        child: Text(
          '$quantity',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: ink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      _quantityButton(Icons.add, onPlus),
    ],
  );

  Widget _quantityButton(IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDE2DE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 15, color: ink),
    ),
  );

  Widget _emptyCart() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: fmGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: fmGreen,
              size: 42,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Keranjangmu masih kosong',
            style: TextStyle(
              color: ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Yuk, pesan kopi atau snack favoritmu di FamilyMart!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF77817D), fontSize: 13),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => setState(() => _selectedTab = 1),
            style: ElevatedButton.styleFrom(
              backgroundColor: fmGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lihat Katalog'),
          ),
        ],
      ),
    ),
  );

  Widget _buildAccount() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
    children: [
      const Text(
        'Akun Member',
        style: TextStyle(color: ink, fontSize: 24, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [fmGreen, fmBlue]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: const [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_rounded, color: fmGreen, size: 28),
            ),
            SizedBox(width: 13),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, Sobat FamilyMart!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'member@familymart.co.id',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      _accountTile(Icons.receipt_long_outlined, 'Riwayat transaksi'),
      _accountTile(
        Icons.store_mall_directory_outlined,
        'Lokasi gerai terdekat',
      ),
      _accountTile(Icons.help_outline_rounded, 'Bantuan & layanan pelanggan'),
      const SizedBox(height: 18),
      FilledButton.icon(
        key: const Key('admin-login-button'),
        onPressed: _openAdminLogin,
        icon: const Icon(Icons.admin_panel_settings_outlined),
        label: const Text('Masuk Admin'),
        style: FilledButton.styleFrom(
          backgroundColor: fmGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    ],
  );

  Widget _accountTile(IconData icon, String title) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: fmBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: fmBlue, size: 20),
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: ink,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF929A96)),
    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ini terhubung ke tabel transaksi & user.'),
        behavior: SnackBarBehavior.floating,
      ),
    ),
  );

  void _checkout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_outline_rounded,
          color: fmGreen,
          size: 42,
        ),
        title: const Text('Transaksi Berhasil Dibuat'),
        content: const Text(
          'Data pesanan siap dikirim ke tabel `transaksi` dengan status "pending".',
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _cart.clear());
              Navigator.pop(context);
            },
            child: const Text('Selesai', style: TextStyle(color: fmGreen)),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    final digits = price.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[index]);
    }
    return 'Rp$buffer';
  }
}
