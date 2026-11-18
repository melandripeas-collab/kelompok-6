requireMethod('POST');
$in = getJsonInput();
$id = (int)($in['id'] ?? 0);

$stmt = $db->prepare("DELETE FROM items WHERE id = :id AND user_id = :uid");
$stmt->execute([':id' => $id, ':uid' => $user['id']]);

if ($stmt->rowCount() === 0) {
    jsonResponse(false, 'Data tidak ditemukan', null, 404);
}
jsonResponse(true, 'Data berhasil dihapus');