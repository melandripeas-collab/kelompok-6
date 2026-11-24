<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('POST');

$db = (new Database())->connect();
requireAuth($db);
$in = getJsonInput();
$id = (int)($in['id'] ?? 0);
$title = trim((string)($in['title'] ?? ''));
$catId = (int)($in['category_id'] ?? 0);
$price = (float)($in['price'] ?? 0);
$stock = (int)($in['stock'] ?? 0);

if ($id <= 0 || $title === '' || $catId <= 0 || $price <= 0 || $stock < 0) {
    jsonResponse(false, 'Data tidak valid', null, 400);
}

$stmt = $db->prepare(
    'UPDATE produk
     SET nama_produk = :title, harga = :price, stok = :stock,
         id_kategori = :category_id
     WHERE id_produk = :id'
);
$stmt->execute([
    ':title' => $title,
    ':price' => $price,
    ':stock' => $stock,
    ':category_id' => $catId,
    ':id' => $id,
]);

if ($stmt->rowCount() === 0) {
    $cek = $db->prepare('SELECT id_produk FROM produk WHERE id_produk = :id');
    $cek->execute([':id' => $id]);
    if (!$cek->fetch()) {
        jsonResponse(false, 'Data tidak ditemukan', null, 404);
    }
}
jsonResponse(true, 'Data berhasil diperbarui');