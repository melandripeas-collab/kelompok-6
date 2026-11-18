<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('POST');

$db = (new Database())->connect();
$user = requireAuth($db);
$input = getJsonInput();

$rawTitle = $input['title'] ?? null;
$categoryId = filter_var(
    $input['category_id'] ?? null,
    FILTER_VALIDATE_INT
);
$rawDescription = $input['description'] ?? '';
$rawPrice = $input['price'] ?? null;

if (
    !is_string($rawTitle)
    || trim($rawTitle) === ''
    || !$categoryId
    || $categoryId < 1
    || !is_string($rawDescription)
    || !is_numeric($rawPrice)
    || !is_finite((float)$rawPrice)
    || (float)$rawPrice <= 0
) {
    jsonResponse(false, 'Judul, kategori, deskripsi, dan harga harus valid', null, 400);
}

$title = trim($rawTitle);
$description = trim($rawDescription);

$categoryStmt = $db->prepare('SELECT id FROM categories WHERE id = :id LIMIT 1');
$categoryStmt->execute([':id' => $categoryId]);
if (!$categoryStmt->fetch()) {
    jsonResponse(false, 'Kategori tidak ditemukan', null, 400);
}

$stmt = $db->prepare(
    'INSERT INTO items (user_id, category_id, title, description, price)
     VALUES (:user_id, :category_id, :title, :description, :price)'
);
$stmt->execute([
    ':user_id' => $user['id'],
    ':category_id' => $categoryId,
    ':title' => $title,
    ':description' => $description,
    ':price' => (float)$rawPrice,
]);

jsonResponse(
    true,
    'Data berhasil ditambahkan',
    ['id' => (int)$db->lastInsertId()],
    201
);
