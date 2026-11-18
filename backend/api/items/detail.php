<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('GET');

$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if (!$id || $id < 1) {
    jsonResponse(false, 'ID item tidak valid', null, 400);
}

$db = (new Database())->connect();
$user = requireAuth($db);

$stmt = $db->prepare(
    'SELECT i.*, c.name AS category_name
     FROM items i
     JOIN categories c ON c.id = i.category_id
     WHERE i.id = :id AND i.user_id = :user_id
     LIMIT 1'
);
$stmt->execute([
    ':id' => $id,
    ':user_id' => $user['id'],
]);

$item = $stmt->fetch();
if (!$item) {
    jsonResponse(false, 'Data tidak ditemukan', null, 404);
}

jsonResponse(true, 'Detail data', $item);
