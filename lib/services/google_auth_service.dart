import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<Map<String, dynamic>> loginWithGoogle(String backendUrl) async {
    try {
      // Melakukan sign-in menggunakan Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception("Login dibatalkan oleh pengguna");
      }

      // Mendapatkan email dari akun Google
      final String email = googleUser.email;

      // Kirim data ke backend
      final response = await http.post(
        Uri.parse('$backendUrl/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception("Gagal login ke backend: ${response.body}");
      }

      return jsonDecode(response.body);
    } catch (error) {
      throw Exception("Error during Google login: $error");
    }
  }
}
