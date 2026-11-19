// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:markektplace/admin.dart' as admin;
import 'package:markektplace/main.dart';

void main() {
  testWidgets('app opens the customer storefront', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

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
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('admin-login-entry-button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Silakan masuk untuk membuka dashboard admin'),
      findsOneWidget,
    );
    expect(find.text('Ringkasan Toko'), findsNothing);
  });

  testWidgets('admin can edit and delete a product', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: admin.AdminDashboardPage()),
    );

    await tester.tap(find.text('Produk'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Kopi Susu Baru');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Kopi Susu Baru'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus').last);
    await tester.pumpAndSettle();

    expect(find.text('Kopi Susu Baru'), findsNothing);
  });
}
