import 'package:flutter/material.dart';

import 'config/api_config.dart';
import 'login.dart' as login;
import 'services/marketplace_service.dart';
import 'services/session.dart';

void main() => runApp(const MyApp());

// Palet Warna Khas FamilyMart
const Color fmGreen = Color(0xFF009944);
const Color fmBlue = Color(0xFF0080C6);
const Color ink = Color(0xFF192C28);
const Color paper = Color(0xFFF5F8FA);

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.storePage});

  final StorePage? storePage;

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
      home: storePage ?? const StorePage(),
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

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    final rawFoto = json['foto']?.toString().trim() ?? '';
    return StoreProduct(
      idProduk: int.tryParse(json['id_produk'].toString()) ?? 0,
      idKategori: int.tryParse(json['id_kategori'].toString()) ?? 0,
      namaProduk: json['nama_produk']?.toString() ?? '',
      namaKategori: json['nama_kategori']?.toString() ?? '',
      harga: num.tryParse(json['harga'].toString())?.toInt() ?? 0,
      stok: int.tryParse(json['stok'].toString()) ?? 0,
      foto: rawFoto.isEmpty
          ? 'https://via.placeholder.com/400x300.png?text=Produk'
          : ApiConfig.resolveAssetUrl(rawFoto),
    );
  }
}

class StorePage extends StatefulWidget {
  const StorePage({super.key, this.initialProducts, this.initialCategories});

  final List<StoreProduct>? initialProducts;
  final List<String>? initialCategories;

  @override
  State<StorePage> createState() => StorePageState();
}

class StorePageState extends State<StorePage> {
  int _selectedTab = 0;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final Map<int, int> _cart = {};
  List<StoreProduct> _products = [];
  List<String> _categories = ['Semua'];
  bool _isLoading = true;
  String? _loadError;
  Map<String, dynamic>? _currentUser;
  String? _profileError;

  @override
  void initState() {
    super.initState();
    if (widget.initialProducts != null || widget.initialCategories != null) {
      _products = widget.initialProducts ?? [];
      _categories = ['Semua'];
      if (widget.initialCategories != null) {
        _categories.addAll(
          widget.initialCategories!.where((item) => item != 'Semua'),
        );
      }
      _isLoading = false;
    } else {
      _loadMarketplace();
      _loadCurrentUser();
    }
  }

  Future<void> _loadCurrentUser() async {
    if (await Session.getToken() == null) {
      if (!mounted) return;
      setState(() {
        _currentUser = null;
        _profileError = null;
      });
      return;
    }

    try {
      final user = await MarketplaceService.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _currentUser = user;
        _profileError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _currentUser = null;
        _profileError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadMarketplace() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final categories = await MarketplaceService.getCategories();
      final products = await MarketplaceService.getProducts();
      if (!mounted) return;
      setState(() {
        _categories = [
          'Semua',
          ...categories
              .map((category) => category['nama_kategori'].toString())
              .toSet(),
        ];
        _products = products
            .map((product) => StoreProduct.fromJson(product))
            .toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<StoreProduct> get _visibleProducts => _products.where((product) {
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
    await _loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(_loadError!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _loadMarketplace,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
      hintText: 'Cari nama produk atau kategori...',
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
      itemCount: _categories.length - 1,
      separatorBuilder: (context, index) => const SizedBox(width: 15),
      itemBuilder: (context, index) {
        final category = _categories[index + 1];
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
      itemCount: _categories.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final category = _categories[index];
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
    final cartProducts = _products
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

  Widget _buildAccount() {
    final name = _currentUser?['name']?.toString().trim();
    final email = _currentUser?['email']?.toString();
    final isSignedIn = _currentUser != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const Text(
          'Akun Member',
          style: TextStyle(
            color: ink,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [fmGreen, fmBlue]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Icon(Icons.person_rounded, color: fmGreen, size: 28),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name?.isNotEmpty == true ? 'Halo, $name!' : 'Belum masuk',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email ?? _profileError ?? 'Masuk untuk melihat profil',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _accountTile(
          Icons.receipt_long_outlined,
          'Riwayat transaksi',
          onTap: _showTransactionHistory,
        ),
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
          label: Text(isSignedIn ? 'Buka Admin' : 'Masuk Admin'),
          style: FilledButton.styleFrom(
            backgroundColor: fmGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _accountTile(IconData icon, String title, {VoidCallback? onTap}) =>
      ListTile(
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
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF929A96),
        ),
        onTap:
            onTap ??
            () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fitur ini belum tersedia.'),
                behavior: SnackBarBehavior.floating,
              ),
            ),
      );

  Future<void> _showTransactionHistory() async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masuk terlebih dahulu untuk melihat transaksi'),
        ),
      );
      return;
    }

    try {
      final transactions = await MarketplaceService.getTransactions();
      if (!mounted) return;
      final userId = _currentUser!['id'].toString();
      final userTransactions = transactions
          .where((transaction) => transaction['id_user'].toString() == userId)
          .toList();
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Riwayat Transaksi'),
          content: SizedBox(
            width: 420,
            child: userTransactions.isEmpty
                ? const Text('Belum ada transaksi.')
                : ListView(
                    shrinkWrap: true,
                    children: userTransactions.map((transaction) {
                      final total =
                          num.tryParse(transaction['total_harga'].toString()) ??
                          0;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          transaction['nama_produk']?.toString() ?? 'Produk',
                        ),
                        subtitle: Text(
                          '${transaction['tanggal_transaksi']} · ${transaction['status']}',
                        ),
                        trailing: Text('Rp${total.toStringAsFixed(0)}'),
                      );
                    }).toList(),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _checkout() async {
    final token = await Session.getToken();
    if (!mounted) return;
    if (token?.trim().isNotEmpty != true) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => const login.LoginPage(openAdminDashboard: false),
        ),
      );
      if (!mounted || loggedIn != true) return;
      await _loadCurrentUser();
    }

    final items = _cart.entries
        .map((entry) => {'id_produk': entry.key, 'jumlah': entry.value})
        .toList();

    final result = await MarketplaceService.checkout(items);
    if (!mounted) return;

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _cart.clear());
    await _loadMarketplace();
    if (!mounted) return;
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
          'Pesanan tersimpan ke tabel transaksi dengan status pending.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
