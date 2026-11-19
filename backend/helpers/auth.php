<?php
/**
 * Membaca token Bearer dari header Authorization,
 * lalu mencocokkan ke tabel user (kolom api_token).
 */
function getBearerToken(): ?string
{
    $headers = function_exists('getallheaders') ? getallheaders() : [];
    $auth = $headers['Authorization'] ?? $headers['authorization']
         ?? $_SERVER['HTTP_AUTHORIZATION'] ?? '';

    if (preg_match('/Bearer\s+(\S+)/i', $auth, $m)) {
        return $m[1];
    }
    return null;
}

function requireAuth(PDO $db): array
{
    $token = getBearerToken();
    if (!$token) {
        jsonResponse(false, 'Token tidak ditemukan', null, 401);
    }

    $stmt = $db->prepare(
        'SELECT id_user AS id, nama AS name, email
         FROM `user` WHERE api_token = :token LIMIT 1'
    );
    $stmt->execute([':token' => $token]);
    $user = $stmt->fetch();

    if (!$user) {
        jsonResponse(false, 'Token tidak valid', null, 401);
    }
    return $user;
}