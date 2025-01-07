import 'dart:convert';
import 'dart:io';
import 'package:frontend/models/product.dart';
import 'package:frontend/utils/token_manager.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/services/google_services.dart';

class ProductService {
  final String baseUrl = 'https://blankis-pakis.vercel.app';

  Future<List<Product>> fetchProducts() async {
    try {
      final token = await TokenManager.getToken();
      final kategoriId = await TokenManager.getKategoriId();
      print(kategoriId);
      if (token == null) {
        throw Exception('Token not found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/products/$kategoriId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
  print(response.body); 
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((product) => Product.fromJson(product as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to fetch products. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching products: $error');
      rethrow;
    }
  }

  Future<void> createProduct(Product product, File? imageFile) async {
    final url = Uri.parse('$baseUrl/products');
    final token = await TokenManager.getToken();

     final kategoriId = await TokenManager.getKategoriId();
      print(kategoriId);
    String? imageUrl;
    if (imageFile != null) {
      final googleDriveService = GoogleDriveService();
      imageUrl = await googleDriveService.uploadFileToGoogleDrive(imageFile);
      print("Image URL (after upload): $imageUrl");
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nama_produk': product.namaProduk,
        'deskripsi': product.deskripsi,
        'kategori': kategoriId,
        'image': imageUrl,
        'harga': product.harga, // Kirim harga ke backend
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create product: ${response.body}');
    }
  }

  Future<void> updateProduct(Product product, File? imageFile) async {
    final url = Uri.parse('$baseUrl/products/${product.id}');
    final token = await TokenManager.getToken();
    final kategoriId = await TokenManager.getKategoriId();
      print(kategoriId);
    String? newImageUrl = product.image;

    if (imageFile != null) {
      final googleDriveService = GoogleDriveService();
      newImageUrl = await googleDriveService.uploadFileToGoogleDrive(imageFile);
      print("New image URL: $newImageUrl");
    }

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nama_produk': product.namaProduk,
        'deskripsi': product.deskripsi,
        'kategori': kategoriId,
        'image': newImageUrl,
        'harga': product.harga, // Kirim harga ke backend
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update product: ${response.body}');
    }

    print('Product updated successfully: ${product.id}');
  }

  Future<void> deleteProduct(int id) async {
    final url = Uri.parse('$baseUrl/products/$id');
    final token = await TokenManager.getToken();

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      print('Delete response: ${response.body}');
      throw Exception('Failed to delete product');
    }

    print('Product deleted successfully: $id');
  }
}
