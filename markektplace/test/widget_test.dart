// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:markektplace/admin.dart' as admin;
import 'package:markektplace/main.dart';

void main() {
  testWidgets('app opens the customer storefront', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(
        storePage: StorePage(
          initialCategories: ['FamiCafé'],
          initialProducts: [
            StoreProduct(
              idProduk: 1,
              idKategori: 1,
              namaProduk: 'Kopi Susu',
              namaKategori: 'FamiCafé',
              harga: 18000,
              stok: 50,
              foto: '',
            ),
          ],
        ),
      ),
    );

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Menu & Produk Favorit'), findsOneWidget);
    expect(find.byKey(const Key('admin-login-entry-button')), findsOneWidget);
    expect(
      find.text('Silakan masuk untuk membuka dashboard admin'),
      findsNothing,
    );
  });

  testWidgets('admin login opens from the storefront', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MyApp(
        storePage: StorePage(initialCategories: [], initialProducts: []),
      ),
    );

    await tester.tap(find.byKey(const Key('admin-login-entry-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Silakan masuk untuk membuka dashboard admin'),
      findsOneWidget,
    );
    expect(find.text('Ringkasan Toko'), findsNothing);
  });

  testWidgets('checkout asks the customer to log in when no token exists', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const MyApp(
        storePage: StorePage(
          initialCategories: ['FamiCafé'],
          initialProducts: [
            StoreProduct(
              idProduk: 1,
              idKategori: 1,
              namaProduk: 'Kopi Susu',
              namaKategori: 'FamiCafé',
              harga: 18000,
              stok: 5,
              foto: '',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.tap(find.text('Keranjang'));
    await tester.pumpAndSettle();
    ScaffoldMessenger.of(
      tester.element(find.text('Checkout Transaksi')),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Checkout Transaksi'));
    await tester.pumpAndSettle();

    expect(
      find.text('Silakan masuk untuk melanjutkan checkout'),
      findsOneWidget,
    );
  });

  testWidgets('admin product management shows database-shaped product', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: admin.AdminDashboardPage(
          initialCategories: const [
            {'id_kategori': 1, 'nama_kategori': 'FamiCafé'},
          ],
          initialProducts: [
            {
              'id_produk': 1,
              'nama_produk': 'Kopi Susu Baru',
              'kategori': 'FamiCafé',
              'nama_kategori': 'FamiCafé',
              'id_kategori': 1,
              'harga': 18000,
              'stok': 50,
            },
          ],
          initialTransactions: const [],
        ),
      ),
    );

    await tester.tap(find.text('Produk'));
    await tester.pumpAndSettle();

    expect(find.text('Kopi Susu Baru'), findsOneWidget);
  });
}
