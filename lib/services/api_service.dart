import 'dart:convert';
import 'package:frontend/utils/token_manager.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://blankispakis.my.id'; // Ganti dengan URL backend Anda

  // Method generik untuk POST
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl${endpoint.startsWith('/') ? '' : '/'}$endpoint');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (await TokenManager.getToken() != null)
          'Authorization': 'Bearer ${await TokenManager.getToken()}',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to perform POST request: ${response.body}');
    }
  }

  Future<List<dynamic>> get(String endpoint) async {
    final url = Uri.parse('$baseUrl${endpoint.startsWith('/') ? '' : '/'}$endpoint');
    final token = await TokenManager.getToken();
    print("token : $token");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to perform GET request: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl${endpoint.startsWith('/') ? '' : '/'}$endpoint');
    final token = await TokenManager.getToken();
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to perform PUT request: ${response.body}');
    }
  }
}