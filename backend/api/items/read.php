<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('GET');

$db = (new Database())->connect();
$user = requireAuth($db);

$search = trim($_GET['search'] ?? '');
$categoryId = (int)($_GET['category_id'] ?? 0);

$sql = 'SELECT i.id, i.title, i.description, i.price, i.category_id,
               c.name AS category_name, i.created_at
        FROM items i
        JOIN categories c ON c.id = i.category_id
        WHERE i.user_id = :user_id';
$params = [':user_id' => $user['id']];

if ($search !== '') {
    $sql .= ' AND i.title LIKE :search';
    $params[':search'] = "%{$search}%";
}

if ($categoryId > 0) {
    $sql .= ' AND i.category_id = :category_id';
    $params[':category_id'] = $categoryId;
}

$sql .= ' ORDER BY i.id DESC';

$stmt = $db->prepare($sql);
$stmt->execute($params);

jsonResponse(true, 'Data berhasil diambil', $stmt->fetchAll());
