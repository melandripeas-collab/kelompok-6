<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/response.php';

setHeaders();
requireMethod('POST');

$in = getJsonInput();
$email = trim($in['email'] ?? '');
$pass  = $in['password'] ?? '';

$db = (new Database())->connect();
$stmt = $db->prepare(
    'SELECT id_user AS id, nama AS name, email, password
     FROM `user` WHERE email = :email LIMIT 1'
);
$stmt->execute([':email' => $email]);
$user = $stmt->fetch();

if (!$user) {
    jsonResponse(false, 'Email atau password salah', null, 401);
}

$storedPassword = (string)$user['password'];
$passwordMatches = password_verify($pass, $storedPassword);
if (
    !$passwordMatches
    && empty(password_get_info($storedPassword)['algo'])
    && hash_equals($storedPassword, $pass)
) {
    $rehash = $db->prepare('UPDATE `user` SET password = :password WHERE id_user = :id');
    $rehash->execute([
        ':password' => password_hash($pass, PASSWORD_DEFAULT),
        ':id' => $user['id'],
    ]);
    $passwordMatches = true;
}

if (!$passwordMatches) {
    jsonResponse(false, 'Email atau password salah', null, 401);
}

$token = bin2hex(random_bytes(32));
$upd = $db->prepare('UPDATE `user` SET api_token = :t WHERE id_user = :id');
$upd->execute([':t' => $token, ':id' => $user['id']]);

jsonResponse(true, 'Login berhasil', [
    'token' => $token,
    'user'  => ['id' => (int)$user['id'], 'name' => $user['name'], 'email' => $user['email']],
]);