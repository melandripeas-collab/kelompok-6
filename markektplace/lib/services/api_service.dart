import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'session.dart';

class ApiResult {
  final bool success;
  final String message;
  final dynamic data;
  ApiResult(this.success, this.message, this.data);
}

class ApiService {
  static Future<Map<String, String>> _headers() async {
    final token = await Session.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static ApiResult _parse(http.Response r) {
    try {
      final j = jsonDecode(r.body);
      return ApiResult(j['success'] == true, j['message'] ?? '', j['data']);
    } catch (_) {
      return ApiResult(
        false,
        'Respon server tidak valid (${r.statusCode})',
        null,
      );
    }
  }

  static Future<ApiResult> get(String path) async {
    try {
      final r = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: 15));
      return _parse(r);
    } catch (e) {
      return ApiResult(false, 'Tidak dapat terhubung ke server', null);
    }
  }

  static Future<ApiResult> post(String path, Map<String, dynamic> body) async {
    try {
      final r = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return _parse(r);
    } catch (e) {
      return ApiResult(false, 'Tidak dapat terhubung ke server', null);
    }
  }
}
