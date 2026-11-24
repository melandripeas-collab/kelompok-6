<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('POST');

$db = (new Database())->connect();
requireAuth($db);
$in = getJsonInput();
$id = (int)($in['id_kategori'] ?? 0);
$name = trim((string)($in['nama_kategori'] ?? ''));
if ($id <= 0 || $name === '') {
    jsonResponse(false, 'Data kategori tidak valid', null, 400);
}

$stmt = $db->prepare(
    'UPDATE kategori SET nama_kategori = :name WHERE id_kategori = :id'
);
$stmt->execute([':name' => $name, ':id' => $id]);
jsonResponse(true, 'Kategori berhasil diperbarui');
