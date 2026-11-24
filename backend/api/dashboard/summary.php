<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('GET');

$db = (new Database())->connect();
requireAuth($db);

$summary = [
    'total_produk' => (int)$db->query('SELECT COUNT(*) FROM produk')->fetchColumn(),
    'total_kategori' => (int)$db->query('SELECT COUNT(*) FROM kategori')->fetchColumn(),
    'total_transaksi' => (int)$db->query('SELECT COUNT(*) FROM transaksi')->fetchColumn(),
    'total_user' => (int)$db->query('SELECT COUNT(*) FROM user')->fetchColumn(),
];

jsonResponse(true, 'Ringkasan berhasil diambil', $summary);
