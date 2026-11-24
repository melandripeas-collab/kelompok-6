<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';

setHeaders();
requireMethod('POST');

$in = getJsonInput();
$name  = trim((string)($in['name'] ?? ''));
$email = strtolower(trim((string)($in['email'] ?? '')));
$pass  = (string)($in['password'] ?? '');

if ($name === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($pass) < 6) {
    jsonResponse(false, 'Data tidak valid (password min. 6 karakter)', null, 400);
}

$db = (new Database())->connect();

$cek = $db->prepare('SELECT id_user FROM `user` WHERE LOWER(email) = :email');
$cek->execute([':email' => $email]);
if ($cek->fetch()) {
    jsonResponse(false, 'Email sudah terdaftar', null, 409);
}

$stmt = $db->prepare('INSERT INTO `user` (nama, email, password) VALUES (:n, :e, :p)');
$stmt->execute([
    ':n' => $name,
    ':e' => $email,
    ':p' => password_hash($pass, PASSWORD_DEFAULT),
]);

jsonResponse(true, 'Registrasi berhasil', ['id' => (int)$db->lastInsertId()], 201);