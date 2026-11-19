import 'package:flutter/material.dart';

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
      title: 'Admin Dashboard - FamilyMart',
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
      home: const AdminDashboardPage(),
    );
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;

  // Data Kategori (Sesuai tabel `kategori`)
  final List<Map<String, dynamic>> _categories = [
    {'id_kategori': 1, 'nama_kategori': 'FamiCafé'},
    {'id_kategori': 2, 'nama_kategori': 'Siap Saji'},
    {'id_kategori': 3, 'nama_kategori': 'Oden & Snack'},
    {'id_kategori': 4, 'nama_kategori': 'Minuman'},
  ];

  // Data Produk (Sesuai tabel `produk`)[cite: 23]
  final List<Map<String, dynamic>> _products = [
    {
      'id_produk': 1,
      'nama_produk': 'Kopi Susu Keluarga (KSK)',
      'kategori': 'FamiCafé',
      'harga': 18000.00,
      'stok': 50,
    },
    {
      'id_produk': 2,
      'nama_produk': 'Onigiri Tuna Mayo',
      'kategori': 'Siap Saji',
      'harga': 14000.00,
      'stok': 30,
    },
    {
      'id_produk': 3,
      'nama_produk': 'Oden Kuah Tomyum',
      'kategori': 'Oden & Snack',
      'harga': 19000.00,
      'stok': 20,
    },
    {
      'id_produk': 4,
      'nama_produk': 'Air Mineral 600ml',
      'kategori': 'Minuman',
      'harga': 5000.00,
      'stok': 100,
    },
  ];

  // Data Transaksi (Sesuai tabel `transaksi`)[cite: 23]
  final List<Map<String, dynamic>> _transactions = [
    {
      'id_transaksi': 1,
      'nama_user': 'Sobat FamilyMart',
      'nama_produk': 'Kopi Susu Keluarga (KSK)',
      'jumlah': 2,
      'total_harga': 36000.00,
      'status': 'pending',
      'tanggal': '2026-11-12 08:30:00',
    },
    {
      'id_transaksi': 2,
      'nama_user': 'Budi Santoso',
      'nama_produk': 'Onigiri Tuna Mayo',
      'jumlah': 1,
      'total_harga': 14000.00,
      'status': 'success',
      'tanggal': '2026-11-12 09:15:00',
    },
  ];

  // Fungsi untuk memunculkan dialog tambah kategori baru
  void _showAddCategoryDialog() {
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Tambah Kategori Baru',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: categoryController,
          decoration: InputDecoration(
            labelText: 'Nama Kategori',
            hintText: 'Contoh: Roti & Bakery',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (categoryController.text.isNotEmpty) {
                setState(() {
                  _categories.add({
                    'id_kategori': _categories.length + 1,
                    'nama_kategori': categoryController.text,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kategori berhasil ditambahkan!'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: fmGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProductDialog(Map<String, dynamic> product) async {
    final updatedProduct = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) =>
          _EditProductDialog(product: product, categories: _categories),
    );

    if (updatedProduct == null || !mounted) return;
    setState(() => product.addAll(updatedProduct));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Produk berhasil diperbarui')));
  }

  Future<void> _confirmDeleteProduct(Map<String, dynamic> product) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Hapus "${product['nama_produk']}" dari daftar produk?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;
    setState(() {
      _products.removeWhere(
        (item) => item['id_produk'] == product['id_produk'],
      );
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('admin-back-button'),
          tooltip: 'Kembali',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: fmGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                children: [
                  TextSpan(
                    text: 'Admin ',
                    style: TextStyle(color: ink),
                  ),
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
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            key: const Key('switch-to-store-button'),
            tooltip: 'Beralih ke toko',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.storefront_outlined, color: fmGreen),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE8EBE7), height: 1),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardOverview(),
          _buildProductManagement(),
          _buildTransactionManagement(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: fmGreen.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: fmGreen),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: fmGreen),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: fmGreen),
            label: 'Transaksi',
          ),
        ],
      ),
    );
  }

  // 1. Tampilan Utama Dashboard (Transaksi Terbaru Dihapus, Ditambah Info Ringkas)
  Widget _buildDashboardOverview() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Ringkasan Toko',
          style: TextStyle(
            color: ink,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Monitoring database `db_marketplace` secara real-time.',
          style: TextStyle(color: Color(0xFF77817D), fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Grid Kartu Statistik (Mengacu pada tabel user, produk, kategori, transaksi)[cite: 23]
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: [
            _statCard(
              'Total Produk',
              '${_products.length}',
              Icons.inventory,
              fmGreen,
              'Tabel produk',
            ),
            _statCard(
              'Kategori',
              '${_categories.length}',
              Icons.category,
              fmBlue,
              'Tabel kategori',
            ),
            _statCard(
              'Transaksi',
              '${_transactions.length}',
              Icons.shopping_cart,
              Colors.orange,
              'Tabel transaksi',
            ),
            _statCard('User', '1', Icons.people, Colors.purple, 'Tabel user'),
          ],
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 22),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF929A96), fontSize: 10),
          ),
        ],
      ),
    );
  }

  // 2. Tampilan Manajemen Produk & Kategori (Sesuai tabel `produk` & `kategori`)[cite: 23]
  Widget _buildProductManagement() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: fmGreen,
              unselectedLabelColor: Colors.grey,
              indicatorColor: fmGreen,
              tabs: [
                Tab(text: 'Daftar Produk'),
                Tab(text: 'Kelola Kategori'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1: List Produk
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Produk Tersedia',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Form tambah produk baru'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Tambah'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: fmGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _products.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final p = _products[index];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: fmGreen.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.fastfood,
                                      color: fmGreen,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p['nama_produk'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: ink,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Kategori: ${p['kategori']} | Stok: ${p['stok']}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF77817D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'Rp${p['harga'].toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: fmGreen,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit produk',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () =>
                                            _showEditProductDialog(p),
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: fmBlue,
                                          size: 20,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Hapus produk',
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () =>
                                            _confirmDeleteProduct(p),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab 2: List & Tambah Kategori
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Daftar Kategori',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ink,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddCategoryDialog, // Tombol untuk memunculkan pop-up tambah kategori
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Tambah Kategori'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: fmBlue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _categories.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.category,
                                    color: fmBlue,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      cat['nama_kategori'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: ink,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'ID: ${cat['id_kategori']}',
                                    style: const TextStyle(
                                      color: Color(0xFF929A96),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Tampilan Manajemen Transaksi (Sesuai tabel `transaksi`)[cite: 23]
  Widget _buildTransactionManagement() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Transaksi',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kelola status pesanan dari tabel `transaksi`.',
            style: TextStyle(color: Color(0xFF77817D), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final t = _transactions[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ID Transaksi: #${t['id_transaksi']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: fmBlue,
                            ),
                          ),
                          Text(
                            t['tanggal'],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF929A96),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Text(
                        'Pembeli: ${t['nama_user']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: ink,
                        ),
                      ),
                      Text(
                        'Produk: ${t['nama_produk']} (${t['jumlah']}x)',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF77817D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: Rp${t['total_harga'].toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: fmGreen,
                              fontSize: 14,
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                t['status'] = t['status'] == 'pending'
                                    ? 'success'
                                    : 'pending';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: t['status'] == 'success'
                                  ? fmGreen
                                  : Colors.orange,
                              side: BorderSide(
                                color: t['status'] == 'success'
                                    ? fmGreen
                                    : Colors.orange,
                              ),
                              minimumSize: const Size(80, 30),
                            ),
                            child: Text(
                              t['status'].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProductDialog extends StatefulWidget {
  const _EditProductDialog({required this.product, required this.categories});

  final Map<String, dynamic> product;
  final List<Map<String, dynamic>> categories;

  @override
  State<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.product['nama_produk'] as String,
    );
    _priceController = TextEditingController(
      text: (widget.product['harga'] as num).toStringAsFixed(0),
    );
    _stockController = TextEditingController(
      text: widget.product['stok'].toString(),
    );
    _selectedCategory = widget.product['kategori'] as String;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context, <String, dynamic>{
      'nama_produk': _nameController.text.trim(),
      'kategori': _selectedCategory,
      'harga': num.parse(_priceController.text),
      'stok': int.parse(_stockController.text),
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit Produk'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama produk'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Nama produk wajib diisi'
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: widget.categories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category['nama_kategori'] as String,
                      child: Text(category['nama_kategori'] as String),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga'),
              validator: (value) {
                final price = num.tryParse(value ?? '');
                return price == null || price <= 0
                    ? 'Masukkan harga yang valid'
                    : null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stok'),
              validator: (value) {
                final stock = int.tryParse(value ?? '');
                return stock == null || stock < 0
                    ? 'Masukkan stok yang valid'
                    : null;
              },
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Batal'),
      ),
      ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: fmGreen,
          foregroundColor: Colors.white,
        ),
        child: const Text('Simpan'),
      ),
    ],
  );
}
