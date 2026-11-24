<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('POST');

$db = (new Database())->connect();
$user = requireAuth($db);
$items = getJsonInput()['items'] ?? [];
if (!is_array($items) || count($items) === 0) {
    jsonResponse(false, 'Keranjang kosong', null, 400);
}

$db->beginTransaction();
try {
    $insert = $db->prepare(
        'INSERT INTO transaksi (id_user, id_produk, jumlah, total_harga, status)
         VALUES (:id_user, :id_produk, :jumlah, :total_harga, :status)'
    );
    $count = 0;

    foreach ($items as $item) {
        $productId = (int)($item['id_produk'] ?? 0);
        $quantity = (int)($item['jumlah'] ?? 0);
        if ($productId <= 0 || $quantity <= 0) {
            throw new InvalidArgumentException('Item keranjang tidak valid');
        }

        $check = $db->prepare(
            'SELECT id_produk, nama_produk, harga, stok
             FROM produk WHERE id_produk = :id LIMIT 1'
        );
        $check->execute([':id' => $productId]);
        $product = $check->fetch();
        if (!$product || (int)$product['stok'] < $quantity) {
            throw new InvalidArgumentException('Stok produk tidak mencukupi');
        }

        $total = (float)$product['harga'] * $quantity;
        $insert->execute([
            ':id_user' => $user['id'],
            ':id_produk' => $productId,
            ':jumlah' => $quantity,
            ':total_harga' => $total,
            ':status' => 'pending',
        ]);

        $update = $db->prepare(
            'UPDATE produk SET stok = stok - :quantity WHERE id_produk = :id'
        );
        $update->execute([':quantity' => $quantity, ':id' => $productId]);
        $count++;
    }

    $db->commit();
    jsonResponse(true, 'Checkout berhasil', ['jumlah_transaksi' => $count], 201);
} catch (InvalidArgumentException $e) {
    $db->rollBack();
    jsonResponse(false, $e->getMessage(), null, 400);
} catch (Throwable $e) {
    $db->rollBack();
    jsonResponse(false, 'Checkout gagal diproses', null, 500);
}
