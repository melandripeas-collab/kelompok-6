<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('POST');

$db = (new Database())->connect();
requireAuth($db);
$id = (int)(getJsonInput()['id_kategori'] ?? 0);
if ($id <= 0) {
    jsonResponse(false, 'ID kategori tidak valid', null, 400);
}

$stmt = $db->prepare('DELETE FROM kategori WHERE id_kategori = :id');
$stmt->execute([':id' => $id]);
if ($stmt->rowCount() === 0) {
    jsonResponse(false, 'Kategori tidak ditemukan', null, 404);
}
jsonResponse(true, 'Kategori berhasil dihapus');
