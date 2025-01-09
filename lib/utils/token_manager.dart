import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  // Simpan token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Simpan user ID
  static Future<void> saveUserId(dynamic user_id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user_id.toString());
    print('User ID saved: ${user_id.toString()}');
  }

  // Simpan kategori ID
  static Future<void> saveKategoriId(dynamic kategori_id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kategori_id', kategori_id.toString());
    print('Kategori ID saved: ${kategori_id.toString()}');
  }

  // Simpan email dan password
  static Future<void> saveLoginData(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
    print('Login data saved: Email: $email, Password: $password');
  }

  // Ambil token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Ambil user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Ambil kategori ID
  static Future<String?> getKategoriId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('kategori_id');
  }


  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email'); // Ambil email user yang tersimpan
  }
  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('password'); // Ambil email user yang tersimpan
  }
  
  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email); // Simpan email saat login
  }
 static Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('password', password); // Simpan email saat login
  }

  // Hapus token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
