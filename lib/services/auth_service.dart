
import 'package:frontend/services/api_service.dart';

class AuthService {
  static final ApiService _apiService = ApiService();

  static Future<void> register(String username, String email, String password, String role, String kategori) async {
    await _apiService.post('/auth/register', {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      'kategori': kategori,
    });
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    return await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });
  }
static Future<void> updatePassword(String email, String currentPassword, String newPassword) async {
  await _apiService.put('/auth/update-password', {
    'email': email,
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  });
}



}
