<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';
require_once __DIR__ . '/../../helpers/auth.php';

setHeaders();
requireMethod('GET');

$db = (new Database())->connect();
$user = requireAuth($db);

jsonResponse(true, 'Profil berhasil diambil', $user);
