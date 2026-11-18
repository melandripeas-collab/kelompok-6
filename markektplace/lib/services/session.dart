import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static Future<void> saveToken(String t) async =>
      (await SharedPreferences.getInstance()).setString('token', t);
  static Future<String?> getToken() async =>
      (await SharedPreferences.getInstance()).getString('token');
  static Future<void> clear() async =>
      (await SharedPreferences.getInstance()).remove('token');
}
