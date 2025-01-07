import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/screens/history_page.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/services/order_service.dart';
import 'package:frontend/services/product_service.dart';
import 'package:frontend/services/google_services.dart';
import 'package:frontend/utils/token_manager.dart';
import 'login_page.dart';
import 'package:flutter/services.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // Service untuk memanggil API produk
  final productService = ProductService();

  // Keranjang belanja: key = Product, value = jumlah
  final Map<Product, int> cart = {};

  // Future yang akan memuat data produk
  late Future<List<Product>> products;

  // RajaOngkir (jika butuh integrasi real)
  int totalHarga = 0;
  @override
  void initState() {
    super.initState();
    products = productService.fetchProducts();
    _loadCart();
  }

  // Memuat keranjang dari SharedPreferences
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart');
    if (cartString != null) {
      final Map<String, dynamic> cartData = jsonDecode(cartString);
      final productList = await products; // tunggu data product

      setState(() {
        cart.clear();
        cartData.forEach((id, quantity) {
          final product = productList.firstWhere(
            (p) => p.id.toString() == id,
            orElse: () {
              print('Product with ID $id not found in productList');
              return Product(
                id: -1,
                namaProduk: 'Unknown',
                deskripsi: 'Not Found',
                image: null,
                kategori: 'Unknown',
                harga: 0,
              );
            },
          );

          if (product.id != -1) {
            cart[product] = quantity;
          }
        });
      });
      print('Loaded cart: $cart');
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData =
        cart.map((product, qty) => MapEntry(product.id.toString(), qty));
    await prefs.setString('cart', jsonEncode(cartData));

    // Log data yang disimpan
    print('Cart saved: ${jsonEncode(cartData)}');
  }

  void _addToCart(Product product) {
    setState(() {
      cart.update(product, (existingQty) => existingQty + 1, ifAbsent: () => 1);
    });
    _saveCart();
  }

  // Hapus produk dari keranjang
  void _removeFromCart(Product product) {
    setState(() {
      cart.remove(product);
    });
    _saveCart();
  }

void _showCartDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final totalPrice = cart.entries.fold<int>(
        0,
        (sum, entry) => sum + (entry.key.harga * entry.value),
      );
      return AlertDialog(
        title: const Text(
          "Keranjang",
          style: TextStyle(
            color: Color(0xFF6B4226), // Warna coklat gelap
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // List item di keranjang
              ...cart.entries.map((entry) {
                final product = entry.key;
                final qty = entry.value;
                final subtotal = product.harga * qty;
                return ListTile(
                  leading: (product.image != null && product.image!.isNotEmpty)
                      ? Image.network(product.image!,
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(
                          Icons.image,
                          size: 50,
                          color: Color(0xFF6B4226), // Ikon coklat gelap
                        ),
                  title: Text(
                    product.namaProduk,
                    style: const TextStyle(
                      color: Color(0xFF6B4226), // Warna teks coklat
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Qty: $qty",
                        style: const TextStyle(color: Color(0xFF6B4226)),
                      ),
                      Text(
                        "Subtotal: Rp $subtotal",
                        style: const TextStyle(color: Color(0xFF6B4226)),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Color(0xFF6B4226), // Ikon delete coklat gelap
                    ),
                    onPressed: () {
                      _removeFromCart(product);
                      Navigator.pop(context);
                      _showCartDialog(); // refresh dialog
                    },
                  ),
                );
              }).toList(),
              const Divider(color: Color(0xFF6B4226)), // Divider coklat gelap
              // Total keseluruhan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Harga:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF6B4226), // Warna coklat gelap
                    ),
                  ),
                  Text(
                    "Rp $totalPrice",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFF9B14F), // Warna emas
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tutup",
              style: TextStyle(color: Color(0xFF6B4226)), // Tombol coklat gelap
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9B14F), // Warna emas
            ),
            onPressed: () {
              Navigator.pop(context);
              _showPaymentForm(totalPrice);
            },
            child: const Text(
              "Bayar",
              style: TextStyle(color: Color(0xFF6B4226)), // Teks coklat gelap
            ),
          ),
        ],
      );
    },
  );
}

void _showProductDetail(BuildContext context, Product product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          product.namaProduk,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B4226), // Warna coklat gelap
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            product.image != null
                ? Image.network(product.image!, fit: BoxFit.cover)
                : const Icon(
                    Icons.image,
                    size: 100,
                    color: Color(0xFF6B4226), // Ikon coklat gelap
                  ),
            const SizedBox(height: 10),
            Text(
              product.deskripsi,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B4226), // Warna coklat
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tutup",
              style: TextStyle(color: Color(0xFF6B4226)), // Tombol coklat gelap
            ),
          ),
        ],
      );
    },
  );
}

  void _showPaymentForm(int totalPrice) async {
    final TextEditingController addressController = TextEditingController();
    final TextEditingController paymentController = TextEditingController();

    // State untuk dropdown
    List<Map<String, dynamic>> provinceList = [];
    List<String> cityList = [];

    String? selectedProvince;
    String? selectedCity;
    int shippingCost = 0;

    File? paymentProofFile;

    // Load data JSON dari assets
    Future<void> _loadRegions(StateSetter dialogSetState) async {
      try {
        final jsonString = await rootBundle.loadString('assets/regions.json');
        final List<dynamic> data = jsonDecode(jsonString);

        dialogSetState(() {
          provinceList = data.map((e) {
            return {
              "province": e["provinsi"],
              "cities": (e["kota"] as List<dynamic>)
                  .map((city) => city as String)
                  .toList(),
            };
          }).toList();
        });
      } catch (error) {
        print("Error loading regions: $error");
      }
    }

// Pick image
    Future<void> _pickImage(StateSetter dialogSetState) async {
      final picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        dialogSetState(() {
          paymentProofFile = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            // Panggil _loadRegions hanya sekali
            if (provinceList.isEmpty) {
              _loadRegions(dialogSetState);
            }

            return AlertDialog(
              title: const Text("Form Pembayaran"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dropdown Provinsi
                    DropdownButtonFormField<String>(
                      hint: const Text("Pilih Provinsi"),
                      value: selectedProvince,
                      items: provinceList.map((prov) {
                        return DropdownMenuItem<String>(
                          value: prov["province"],
                          child: Text(prov["province"]),
                        );
                      }).toList(),
                      onChanged: provinceList.isEmpty
                          ? null // Nonaktifkan dropdown jika data belum tersedia
                          : (value) {
                              dialogSetState(() {
                                selectedProvince = value;
                                cityList = provinceList.firstWhere((prov) =>
                                        prov["province"] == value)["cities"]
                                    as List<String>;
                                selectedCity = null; // Reset kota
                              });
                            },
                    ),

                    const SizedBox(height: 10),

                    // Dropdown Kota
                    DropdownButtonFormField<String>(
                      hint: const Text("Pilih Kota/Kabupaten"),
                      value: selectedCity,
                      items: cityList.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: cityList.isEmpty
                          ? null // Nonaktifkan dropdown jika tidak ada kota
                          : (value) {
                              dialogSetState(() {
                                selectedCity = value;
                              });
                            },
                    ),
                    const SizedBox(height: 10),
                    // Alamat
                    TextField(
                      controller: addressController,
                      decoration:
                          const InputDecoration(labelText: "Alamat Lengkap"),
                    ),
                    const SizedBox(height: 10),
                    
                    
                    ElevatedButton(
                      onPressed: () {
                        if (selectedCity == null || selectedProvince == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Pilih provinsi dan kota terlebih dahulu!")),
                          );
                          return;
                        }
                        dialogSetState(() {
                          shippingCost = 15000; // Dummy biaya ongkir
                        });
                      },
                      child: const Text("Cek Ongkir"),
                    ),
                    
                    const SizedBox(height: 10),

                    Text("Ongkos Kirim: Rp $shippingCost"),
                    const SizedBox(height: 10),

                    // Jumlah Bayar
                    TextField(
                      controller: paymentController,
                      decoration:
                          const InputDecoration(labelText: "Jumlah Bayar"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),

                    // Tombol pilih gambar
                    ElevatedButton(
                      onPressed: () => _pickImage(dialogSetState),
                      child: const Text("Pilih Gambar Bukti Bayar"),
                    ),
                    if (paymentProofFile != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(paymentProofFile!,
                            width: 100, height: 100, fit: BoxFit.cover),
                      ),

                    const SizedBox(height: 10),
                    Text("Total Tagihan: Rp ${totalPrice + shippingCost}"),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: () async {
                    final bayar = int.tryParse(paymentController.text) ?? 0;
                    final grandTotal = totalPrice + shippingCost;
                    if (bayar < grandTotal) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pembayaran kurang")),
                      );
                      return;
                    }
                    if (selectedCity == null ||
                        addressController.text.isEmpty ||
                        selectedProvince == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Lengkapi provinsi, kota, dan alamat")),
                      );
                      return;
                    }
                    final provinceName = selectedProvince!;
                    final cityName = selectedCity!;

                    Navigator.pop(context);

                    // Log data pembayaran (dummy)
                    await _processPayment(
                      province: provinceName,
                      city: cityName,
                      address: addressController.text.trim(),
                      shippingCost: shippingCost,
                      totalPrice: totalPrice,
                      paymentFile: paymentProofFile,
                    );
                  },
                  child: const Text("Bayar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Proses pembayaran: upload foto (jika ada), panggil createOrder
  Future<void> _processPayment({
    required String province,
    required String city,
    required String address,
    required int shippingCost,
    required int totalPrice,
    File? paymentFile,
  }) async {
    try {
      final userIdString = await TokenManager.getuserId();
      final userId = int.parse(userIdString!);

      // Upload foto ke Google Drive (jika ada)
      String? paymentProofUrl;
      if (paymentFile != null) {
        final googleDriveService = GoogleDriveService();
        paymentProofUrl =
            await googleDriveService.uploadFileToGoogleDrive(paymentFile);
      }

      // Susun orderDetails
      final orderDetails = cart.entries.map((entry) {
        return {
          "product_id": entry.key.id,
          "quantity": entry.value,
          "price": entry.key.harga,
        };
      }).toList();

      // Panggil OrderService
      final orderService = OrderService();
      await orderService.createOrder(
        userId: userId,
        province: province,
        city: city,
        address: address,
        shippingCost: shippingCost,
        paymentProof: paymentProofUrl,
        totalPrice: totalPrice,
        orderDetails: orderDetails,
      );

      // Bersihkan keranjang
      setState(() {
        cart.clear();
      });
      await _saveCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pembayaran berhasil! Pesanan dibuat.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memproses pembayaran: $e")),
      );
    }
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.brown,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.contact_phone),
            title: const Text('Contact'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              _showContactDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sms),
            title: const Text('SMS'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              _sendSMS();
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Lokasi Toko'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              _navigateToMap();
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History Belanja'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              _navigateToHistoryPage();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Update Password'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              _showUpdatePasswordDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              _logout(); // Fungsi untuk logout
            },
          ),
        ],
      ),
    );
  }
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data di SharedPreferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(), // Kembali ke halaman login
      ),
    );
  }

  /// Menampilkan dialog kontak
  void _showContactDialog(BuildContext context) async {
    final String phoneNumber = '081229984124';
    var status = await Permission.phone.status;

    if (status.isGranted) {
      final Uri telUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka aplikasi telepon')),
        );
      }
    } else {
      // Minta izin jika belum diberikan
      var result = await Permission.phone.request();

      if (result.isGranted) {
        final Uri telUri = Uri(
          scheme: 'tel',
          path: phoneNumber,
        );
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka aplikasi telepon')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin telepon ditolak')),
        );
      }
    }
  }

  /// Mengirim SMS (contoh sederhana menggunakan URL scheme)
  void _sendSMS() {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: '081229984124', // Ganti dengan nomor yang diinginkan
      queryParameters: <String, String>{
        'body': 'Halo, saya ingin menanyakan tentang pesanan saya.'
      },
    );

    launchUrl(smsUri);
  }
   void _navigateToMap() async {
    const String googleMapsUrl = 'https://maps.app.goo.gl/YCXT4wbUkkGMBLqQ8'; // URL Google Maps
    final Uri url = Uri.parse(googleMapsUrl); // Membuat objek Uri dari URL

    //  canLaunchUrl untuk memeriksa apakah URL bisa diakses
    if (await canLaunch(url.toString())) {
      await launch(url.toString()); // Menggunakan launch untuk membuka URL
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
   }

  void _showUpdatePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Future<void> _updatePassword() async {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });

              try {
                final email =
                    "user_email@example.com"; // Ambil email user dari storage/session
                final currentPassword = currentPasswordController.text;
                final newPassword = newPasswordController.text;

                if (currentPassword.isEmpty || newPassword.isEmpty) {
                  setState(() {
                    errorMessage = "Semua field harus diisi!";
                    isLoading = false;
                  });
                  return;
                }

                await AuthService.updatePassword(
                    email, currentPassword, newPassword);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Password berhasil diperbarui!")),
                );

                Navigator.pop(context); // Tutup dialog setelah sukses
              } catch (e) {
                setState(() {
                  errorMessage = "Gagal memperbarui password: ${e.toString()}";
                  isLoading = false;
                });
              }
            }

            return AlertDialog(
              title: const Text("Update Password"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      decoration: const InputDecoration(
                        labelText: "Password Lama",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      decoration: const InputDecoration(
                        labelText: "Password Baru",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : _updatePassword,
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Navigasi ke halaman History Belanja
  Future<void> _navigateToHistoryPage() async {
    // Ambil userId dari TokenManager
    final userIdString = await TokenManager.getuserId();

    if (userIdString != null) {
      final userId = int.parse(userIdString);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HistoryBelanjaPage(userId: userId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID tidak ditemukan.")),
      );
    }
  }

  // Build UI utama
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Page',
          style: TextStyle(color: Color(0xFFF9B14F)),
        ),
        backgroundColor: Color(0xFF5B4F07),
      ),
      drawer: _buildDrawer(), // Drawer muncul
      body: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF9B14F),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: TextStyle(color: Color(0xFFF9B14F)),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada produk.',
                style: TextStyle(color: Color(0xFFF9B14F)),
              ),
            );
          } else {
            final data = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final product = data[index];
                      return Card(
                        color: Color(0xFF0D0D0D),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () => _addToCart(
                                product), // Tambah harga produk ke total
                            child: product.image != null
                                ? Image.network(
                                    product.image!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image,
                                    size: 50, color: Color(0xFFF9B14F)),
                          ),
                          title: GestureDetector(
                            onTap: () => _showProductDetail(
                                context, product), // Tampilkan detail produk
                            child: Text(
                              product.namaProduk,
                              style: TextStyle(
                                color: Color(0xFFF9B14F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          subtitle: Text(
                            "Rp ${product.harga}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Color(0xFF5B4F07),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Harga:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFF9B14F),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF9B14F),
                        ),
                        onPressed: () {
                          _showCartDialog();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.shopping_cart, // Ikon keranjang
                              color: Color(0xFF0D0D0D),
                            ),
                            const SizedBox(
                                width: 8), // Spasi antara ikon dan teks
                            AnimatedSwitcher(
                              duration: const Duration(
                                  milliseconds: 300), // Durasi animasi
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              },
                              child: cart.isNotEmpty
                                  ? Container(
                                      key: ValueKey<int>(
                                          cart.values.reduce((a, b) => a + b)),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${cart.values.reduce((a, b) => a + b)}', // Jumlah item
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : const SizedBox
                                      .shrink(), // Kosong jika tidak ada item
                            ),
                            const SizedBox(
                                width: 8), // Spasi antara jumlah item dan teks
                            const Text(
                              'Keranjang',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0D0D0D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
