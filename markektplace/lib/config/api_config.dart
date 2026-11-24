import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class ApiConfig {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const String _basePath = String.fromEnvironment(
    'API_BASE_PATH',
    defaultValue: '/kelompok-6/backend/api',
  );
  static const String _configuredHost = String.fromEnvironment('API_HOST');
  static const String _configuredPort = String.fromEnvironment(
    'API_PORT',
    defaultValue: '8000',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl.endsWith('/')
          ? _configuredBaseUrl.substring(0, _configuredBaseUrl.length - 1)
          : _configuredBaseUrl;
    }

    final defaultHost =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : '127.0.0.1';
    final host = _configuredHost.isNotEmpty ? _configuredHost : defaultHost;
    const protocol = String.fromEnvironment(
      'API_PROTOCOL',
      defaultValue: 'http',
    );
    final path = _basePath.startsWith('/') ? _basePath : '/$_basePath';
    final normalizedPath = path.endsWith('/')
        ? path.substring(0, path.length - 1)
        : path;
    return '$protocol://$host:$_configuredPort$normalizedPath';
  }

  static String resolveAssetUrl(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;

    const uploadPrefix = 'uploads/products/';
    if (path.startsWith(uploadPrefix)) {
      final imageUri = Uri.parse('$baseUrl/').resolve('products/image.php');
      return imageUri
          .replace(
            queryParameters: {'name': path.substring(uploadPrefix.length)},
          )
          .toString();
    }

    final relativePath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse(baseUrl).resolve(relativePath).toString();
  }
}
