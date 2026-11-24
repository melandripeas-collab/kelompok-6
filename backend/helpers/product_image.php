<?php
function saveProductImage(?array $upload): ?string
{
    if ($upload === null || ($upload['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) {
        return null;
    }

    $error = (int)($upload['error'] ?? UPLOAD_ERR_NO_FILE);
    if ($error !== UPLOAD_ERR_OK) {
        $status = in_array($error, [UPLOAD_ERR_INI_SIZE, UPLOAD_ERR_FORM_SIZE], true)
            ? 413
            : 400;
        jsonResponse(false, 'Foto gagal diunggah', null, $status);
    }

    $temporaryPath = (string)($upload['tmp_name'] ?? '');
    $fileSize = (int)($upload['size'] ?? 0);
    if ($temporaryPath === '' || !is_uploaded_file($temporaryPath)) {
        jsonResponse(false, 'File foto tidak valid', null, 400);
    }
    if ($fileSize <= 0 || $fileSize > 5 * 1024 * 1024) {
        jsonResponse(false, 'Ukuran foto maksimal 5 MB', null, 413);
    }

    $mimeType = (new finfo(FILEINFO_MIME_TYPE))->file($temporaryPath);
    $extensions = [
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
    ];
    $imageInfo = getimagesize($temporaryPath);
    if (
        !isset($extensions[$mimeType])
        || $imageInfo === false
        || ($imageInfo['mime'] ?? null) !== $mimeType
    ) {
        jsonResponse(false, 'Format foto harus JPG, PNG, atau WEBP', null, 400);
    }

    $directory = dirname(__DIR__) . '/uploads/products';
    if (!is_dir($directory) && !mkdir($directory, 0755, true) && !is_dir($directory)) {
        jsonResponse(false, 'Folder penyimpanan foto tidak dapat dibuat', null, 500);
    }

    $relativePath = 'uploads/products/' . bin2hex(random_bytes(16))
        . '.' . $extensions[$mimeType];
    if (!move_uploaded_file($temporaryPath, dirname(__DIR__) . '/' . $relativePath)) {
        jsonResponse(false, 'Foto gagal disimpan', null, 500);
    }

    return $relativePath;
}
