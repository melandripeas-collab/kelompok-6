<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('POST');

$db = (new Database())->connect();
requireAuth($db);
$in = getJsonInput();
$id = (int)($in['id_transaksi'] ?? 0);
$status = strtolower(trim((string)($in['status'] ?? '')));
$allowed = ['pending', 'success', 'cancelled'];

if ($id <= 0 || !in_array($status, $allowed, true)) {
    jsonResponse(false, 'Status transaksi tidak valid', null, 400);
}

$stmt = $db->prepare(
    'UPDATE transaksi SET status = :status WHERE id_transaksi = :id'
);
$stmt->execute([':status' => $status, ':id' => $id]);
if ($stmt->rowCount() === 0) {
    jsonResponse(false, 'Transaksi tidak ditemukan', null, 404);
}
jsonResponse(true, 'Status transaksi berhasil diperbarui');
