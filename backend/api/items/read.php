<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('GET');

$db = (new Database())->connect();

$search = trim($_GET['search'] ?? '');
$categoryId = (int)($_GET['category_id'] ?? 0);

$sql = 'SELECT p.id_produk AS id, p.nama_produk AS title,
               NULL AS description, p.harga AS price,
               p.id_kategori AS category_id, k.nama_kategori AS category_name,
               p.created_at
        FROM produk p
        JOIN kategori k ON k.id_kategori = p.id_kategori';
$params = [];
$where = [];

if ($search !== '') {
    $where[] = 'p.nama_produk LIKE :search';
    $params[':search'] = "%{$search}%";
}

if ($categoryId > 0) {
    $where[] = 'p.id_kategori = :category_id';
    $params[':category_id'] = $categoryId;
}

if ($where) {
    $sql .= ' WHERE ' . implode(' AND ', $where);
}
$sql .= ' ORDER BY p.id_produk DESC';

$stmt = $db->prepare($sql);
$stmt->execute($params);

jsonResponse(true, 'Data berhasil diambil', $stmt->fetchAll());
