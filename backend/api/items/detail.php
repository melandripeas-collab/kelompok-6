<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('GET');

$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if (!$id || $id < 1) {
    jsonResponse(false, 'ID item tidak valid', null, 400);
}

$db = (new Database())->connect();
$user = requireAuth($db);

$stmt = $db->prepare(
    'SELECT p.id_produk AS id, p.nama_produk AS title,
            NULL AS description, p.harga AS price,
            p.id_kategori AS category_id, k.nama_kategori AS category_name,
            p.created_at
     FROM produk p
     JOIN kategori k ON k.id_kategori = p.id_kategori
     WHERE p.id_produk = :id
     LIMIT 1'
);
$stmt->execute([
    ':id' => $id,
]);

$item = $stmt->fetch();
if (!$item) {
    jsonResponse(false, 'Data tidak ditemukan', null, 404);
}

jsonResponse(true, 'Detail data', $item);
