<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('GET');

$db = (new Database())->connect();
// Sementara boleh tanpa auth; aktifkan setelah Hari 4:
// requireAuth($db);

$rows = $db->query('SELECT id, name FROM categories ORDER BY name')->fetchAll();
jsonResponse(true, 'Data kategori', $rows);