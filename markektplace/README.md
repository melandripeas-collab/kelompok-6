# Marketplace

## Jalankan website lokal (Windows/Laragon)

1. Nyalakan MySQL di Laragon. Pastikan database `db_marketplace` tersedia.
2. Salin `backend/.env.example` menjadi `backend/.env`, lalu isi kredensial MySQL.
3. Dari root repository, buka terminal pertama dan jalankan API memakai PHP
   Laragon:

   ```powershell
   $Php = 'C:\laragon\bin\php\php-8.3.36-Win32-vs16-x64\php.exe'
   & $Php -S 127.0.0.1:8000 -t C:\laragon\www
   ```

4. Di terminal kedua, build dan sajikan website:

   ```powershell
   Set-Location C:\laragon\www\kelompok-6\markektplace
   $Php = 'C:\laragon\bin\php\php-8.3.36-Win32-vs16-x64\php.exe'
   flutter pub get
   flutter build web --dart-define=API_BASE_URL=http://127.0.0.1:8000/kelompok-6/backend/api
   & $Php -S 127.0.0.1:8080 -t build\web
   ```

5. Buka `http://127.0.0.1:8080`. API health check:
   `http://127.0.0.1:8000/kelompok-6/backend/api/ping.php`.

Untuk konfigurasi database pertama kali, impor struktur dari
`db_marketplace (1).sql`, lalu jalankan
`backend/database/002_sync_marketplace_data.sql`. Akun yang didaftarkan dari
halaman login disimpan ke tabel `user`; produk, kategori, dan transaksi
disimpan ke tabel masing-masing. Foto produk dipilih dari perangkat (JPG, PNG,
atau WEBP, maksimal 5 MB), disimpan di `backend/uploads/products`, dan path-nya
disimpan pada tabel `produk`. Pengelolaan produk/kategori memerlukan login.

### Alamat API kustom

Pada perangkat atau host lain, berikan alamat API saat menjalankan Flutter:

```powershell
flutter build web --dart-define=API_BASE_URL=http://192.168.1.10:8000/kelompok-6/backend/api
```

Sebagai alternatif, atur `API_HOST`, `API_PORT`, `API_PROTOCOL`, dan
`API_BASE_PATH` secara terpisah.
