# markektplace

A new Flutter project.

## Run the local API (Windows)

Start MySQL, then run this from the repository root in PowerShell and keep the
terminal open:

```powershell
C:\AppServ\php7\php.exe -S 127.0.0.1:8000 -t ..
```

Check that `http://127.0.0.1:8000/kelompok-6/backend/api/ping.php` returns
`"success": true`, then launch the app. Android emulator builds connect through
`10.0.2.2:8000`; web and desktop builds use `127.0.0.1:8000`. Ensure the local
MySQL database credentials in `backend/config/database.php` are correct.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
