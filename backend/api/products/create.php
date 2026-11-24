<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';
require_once __DIR__ . '/../../helpers/product_image.php';

setHeaders();
requireMethod('POST');

$db = (new Database())->connect();
requireAuth($db);
$in = getJsonInput();

$categoryId = (int)($in['id_kategori'] ?? 0);
$name = trim((string)($in['nama_produk'] ?? ''));
$price = (float)($in['harga'] ?? 0);
$stock = (int)($in['stok'] ?? 0);

if ($categoryId <= 0 || $name === '' || $price <= 0 || $stock < 0) {
    jsonResponse(false, 'Data produk tidak valid', null, 400);
}

$cek = $db->prepare('SELECT id_kategori FROM kategori WHERE id_kategori = :id');
$cek->execute([':id' => $categoryId]);
if (!$cek->fetch()) {
    jsonResponse(false, 'Kategori tidak ditemukan', null, 400);
}

$foto = saveProductImage($_FILES['foto'] ?? null);
$stmt = $db->prepare(
    'INSERT INTO produk (id_kategori, nama_produk, harga, stok, foto)
     VALUES (:category_id, :name, :price, :stock, :foto)'
);
$stmt->execute([
    ':category_id' => $categoryId,
    ':name' => $name,
    ':price' => $price,
    ':stock' => $stock,
    ':foto' => $foto !== '' ? $foto : null,
]);

jsonResponse(true, 'Produk berhasil ditambahkan', [
    'id_produk' => (int)$db->lastInsertId(),
], 201);
