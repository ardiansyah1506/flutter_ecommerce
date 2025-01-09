// lib/services/order_service.dart

import 'dart:convert';
import 'package:frontend/utils/token_manager.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/order.dart'; // Import model Order

class OrderService {
  final String baseUrl = 'https://blankispakis.my.id/order';

  /// Membuat pesanan baru (checkout)
  Future<void> createOrder({
    required int userId,
    required String province,
    required String city,
    required String address,
    required int shippingCost,
    String? paymentProof,
    required int totalPrice,
    required List<Map<String, dynamic>> orderDetails,
  }) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/checkout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'province': province,
        'city': city,
        'address': address,
        'shipping_cost': shippingCost,
        'payment_proof': paymentProof,
        'total_price': totalPrice,
        'cart_items': orderDetails,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to checkout: ${response.body}');
    }
  }

  /// Mendapatkan daftar pesanan (history belanja) untuk user tertentu
  Future<List<Order>> getUserOrders(int userId) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
       print("Data diterima: ${response.body}"); // Debugging data
      final List<dynamic> jsonData = json.decode(response.body);

      // Map menjadi List<Order>
      return jsonData.map((orderJson) => Order.fromJson(orderJson)).toList();
    } else {
      throw Exception('Failed to load orders: ${response.body}');
    }
  }

/// Mendapatkan daftar user berdasarkan role (bukan admin)
Future<List<Map<String, dynamic>>> getUsers() async {
  final token = await TokenManager.getToken();
  final userId = await TokenManager.getKategoriId();
  if (token == null) {
    throw Exception('Token not found');
  }

  final response = await http.get(
    Uri.parse('$baseUrl/report/$userId'), // Sesuaikan endpoint
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body); // Parsing sebagai Map
    if (jsonData.containsKey('users')) {
      // Pastikan respons memiliki properti `users`
      return List<Map<String, dynamic>>.from(jsonData['users']); // Ambil data users
    } else {
      throw Exception('Invalid response format: Missing "users" key');
    }
  } else {
    throw Exception('Failed to load users: ${response.body}');
  }
}

// Mendapatkan laporan penjualan
 Future<List<Map<String, dynamic>>> getSalesReport({
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final token = await TokenManager.getToken();
  if (token == null) {
    throw Exception('Token not found');
  }

  String url = '$baseUrl/report/sales';
   if (startDate != null && endDate != null) {
    final start = startDate.toIso8601String().split('T').first; // Hanya ambil tanggal
    final end = endDate.toIso8601String().split('T').first; // Hanya ambil tanggal
    url += '?startDate=$start&endDate=$end';
    print("start: $start");
    print("end: $end");
  }
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
 
  print("url: $url");

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body)['sales'];
  print("response: $jsonData");
    return List<Map<String, dynamic>>.from(jsonData);
  } else {
    throw Exception('Failed to load sales report: ${response.body}');
  }
}

  // Mendapatkan laporan transaksi
  Future<List<Map<String, dynamic>>> getTransactionReport() async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/report/transactions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body)['transactions'];
      return List<Map<String, dynamic>>.from(jsonData);
    } else {
      throw Exception('Failed to load transaction report: ${response.body}');
    }
  }
}