<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';

setHeaders();
requireMethod('GET');

$db = (new Database())->connect();
$search = trim((string)($_GET['search'] ?? ''));
$categoryId = (int)($_GET['id_kategori'] ?? 0);

$sql = 'SELECT p.id_produk, p.id_kategori, p.nama_produk, p.harga,
               p.stok, p.foto, p.created_at, k.nama_kategori
        FROM produk p
        JOIN kategori k ON k.id_kategori = p.id_kategori';
$where = [];
$params = [];

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

jsonResponse(true, 'Produk berhasil diambil', $stmt->fetchAll());
