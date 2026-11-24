<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('GET');

$db = (new Database())->connect();
$rows = $db->query(
    'SELECT id_kategori, nama_kategori
     FROM kategori
     ORDER BY nama_kategori'
)->fetchAll();
jsonResponse(true, 'Data kategori', $rows);