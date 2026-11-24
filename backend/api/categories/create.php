<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('POST');

$db = (new Database())->connect();
requireAuth($db);
$in = getJsonInput();
$name = trim((string)($in['nama_kategori'] ?? ''));

if ($name === '') {
    jsonResponse(false, 'Nama kategori wajib diisi', null, 400);
}

$cek = $db->prepare('SELECT id_kategori FROM kategori WHERE LOWER(nama_kategori) = LOWER(:name)');
$cek->execute([':name' => $name]);
if ($cek->fetch()) {
    jsonResponse(false, 'Kategori sudah ada', null, 409);
}

$stmt = $db->prepare('INSERT INTO kategori (nama_kategori) VALUES (:name)');
$stmt->execute([':name' => $name]);

jsonResponse(true, 'Kategori berhasil ditambahkan', [
    'id_kategori' => (int)$db->lastInsertId(),
    'nama_kategori' => $name,
], 201);
