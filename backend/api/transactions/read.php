<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('GET');

$db = (new Database())->connect();
$user = requireAuth($db);
$stmt = $db->prepare(
    'SELECT t.id_transaksi, t.id_user, t.id_produk, t.jumlah,
            t.total_harga, t.status, t.tanggal_transaksi,
            u.nama AS nama_user, p.nama_produk
     FROM transaksi t
     JOIN user u ON u.id_user = t.id_user
     JOIN produk p ON p.id_produk = t.id_produk
     ORDER BY t.tanggal_transaksi DESC, t.id_transaksi DESC'
);
$stmt->execute();
jsonResponse(true, 'Transaksi berhasil diambil', $stmt->fetchAll());
