requireMethod('POST');
$in = getJsonInput();
$id = (int)($in['id'] ?? 0);
$title = trim($in['title'] ?? '');
$catId = (int)($in['category_id'] ?? 0);

if ($id <= 0 || $title === '' || $catId <= 0) {
    jsonResponse(false, 'Data tidak valid', null, 400);
}

$stmt = $db->prepare("UPDATE items
                      SET title = :t, description = :d, price = :p, category_id = :cid
                      WHERE id = :id AND user_id = :uid");
$stmt->execute([
    ':t' => $title, ':d' => trim($in['description'] ?? ''),
    ':p' => (float)($in['price'] ?? 0), ':cid' => $catId,
    ':id' => $id, ':uid' => $user['id'],
]);

if ($stmt->rowCount() === 0) {
    // bisa juga karena data tidak berubah; cek keberadaan data bila perlu
    jsonResponse(false, 'Data tidak ditemukan atau tidak berubah', null, 404);
}
jsonResponse(true, 'Data berhasil diperbarui');