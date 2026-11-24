<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('POST');

$db = (new Database())->connect();
requireAuth($db);
$in = getJsonInput();

$id = (int)($in['id_produk'] ?? 0);
$categoryId = (int)($in['id_kategori'] ?? 0);
$name = trim((string)($in['nama_produk'] ?? ''));
$price = (float)($in['harga'] ?? 0);
$stock = (int)($in['stok'] ?? 0);
$foto = trim((string)($in['foto'] ?? ''));

if ($id <= 0 || $categoryId <= 0 || $name === '' || $price <= 0 || $stock < 0) {
    jsonResponse(false, 'Data produk tidak valid', null, 400);
}

$stmt = $db->prepare(
    'UPDATE produk
     SET id_kategori = :category_id, nama_produk = :name,
         harga = :price, stok = :stock, foto = :foto
     WHERE id_produk = :id'
);
$stmt->execute([
    ':category_id' => $categoryId,
    ':name' => $name,
    ':price' => $price,
    ':stock' => $stock,
    ':foto' => $foto !== '' ? $foto : null,
    ':id' => $id,
]);

if ($stmt->rowCount() === 0) {
    $cek = $db->prepare('SELECT id_produk FROM produk WHERE id_produk = :id');
    $cek->execute([':id' => $id]);
    if (!$cek->fetch()) {
        jsonResponse(false, 'Produk tidak ditemukan', null, 404);
    }
}

jsonResponse(true, 'Produk berhasil diperbarui');
