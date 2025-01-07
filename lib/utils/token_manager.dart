import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
  static Future<void> saveUserId(dynamic user_id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id',  user_id.toString());
  print('User ID saved: ${user_id.toString()}'); // Tambahkan log
    }
  static Future<void> saveKategoriId(dynamic kategori_id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kategori_id',  kategori_id.toString());
  print('User ID saved: ${kategori_id.toString()}'); // Tambahkan log
    }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  static Future<String?> getuserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
  static Future<String?> getKategoriId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('kategori_id');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
