<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('POST');

$db = (new Database())->connect();
requireAuth($db);
$id = (int)(getJsonInput()['id_produk'] ?? 0);

$stmt = $db->prepare('DELETE FROM produk WHERE id_produk = :id');
$stmt->execute([':id' => $id]);
if ($stmt->rowCount() === 0) {
    jsonResponse(false, 'Produk tidak ditemukan', null, 404);
}
jsonResponse(true, 'Produk berhasil dihapus');
