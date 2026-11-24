<?php
require_once __DIR__ . '/../../helpers/response.php';

setHeaders();
requireMethod('GET');

$name = (string)($_GET['name'] ?? '');
if (!preg_match('/\A[a-f0-9]{32}\.(?:jpg|png|webp)\z/', $name)) {
    jsonResponse(false, 'Nama file foto tidak valid', null, 400);
}

$imagePath = dirname(__DIR__, 2) . '/uploads/products/' . $name;
if (!is_file($imagePath)) {
    jsonResponse(false, 'Foto tidak ditemukan', null, 404);
}

$mimeType = (new finfo(FILEINFO_MIME_TYPE))->file($imagePath);
if (!in_array($mimeType, ['image/jpeg', 'image/png', 'image/webp'], true)) {
    jsonResponse(false, 'Format foto tidak didukung', null, 415);
}

header('Content-Type: ' . $mimeType);
header('Content-Length: ' . filesize($imagePath));
header('Cache-Control: public, max-age=31536000, immutable');
header('X-Content-Type-Options: nosniff');
readfile($imagePath);
