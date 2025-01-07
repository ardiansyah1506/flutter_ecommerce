import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/screens/login_page.dart';
import 'package:frontend/screens/manajemen_user_page.dart';
import 'package:frontend/screens/sales_report_page.dart';
import 'package:frontend/services/product_service.dart';
import 'package:frontend/utils/token_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  
  final ProductService productService = ProductService();
  late Future<List<Product>> products;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    products = productService.fetchProducts();
  }

void showAddProductDialog({Product? existingProduct}) {
    final _formKey = GlobalKey<FormState>();
    final picker = ImagePicker();

    if (existingProduct != null) {
      nameController.text = existingProduct.namaProduk;
      descriptionController.text = existingProduct.deskripsi;
      priceController.text = existingProduct.harga.toString();
    } else {
      nameController.clear();
      descriptionController.clear();
      priceController.clear();
      _image = null;
    }

    Future<void> _pickImage() async {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color(0xFFF5EFE6),
              title: Text(
                existingProduct == null ? 'Add Product' : 'Update Product',
                style: TextStyle(color: Color(0xFF5B4F07), fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Product Name',
                          labelStyle: TextStyle(color: Color(0xFF5B4F07)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF5B4F07)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Product name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Color(0xFF5B4F07)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF5B4F07)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          labelStyle: TextStyle(color: Color(0xFF5B4F07)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF5B4F07)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Price is required';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      _image != null
                          ? Image.file(
                              _image!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : existingProduct?.image != null
                              ? Image.network(
                                  existingProduct!.image!,
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                )
                              : TextButton(
                                  onPressed: _pickImage,
                                  child: Text(
                                    'Pick Image',
                                    style: TextStyle(color: Color(0xFF5B4F07)),
                                  ),
                                ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF5B4F07)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5B4F07),
                  ),
                  onPressed: () async {
                   
                    if (_formKey.currentState!.validate()) {
                    final kategoriId = await TokenManager.getKategoriId();
                      try {
                        if (existingProduct == null) {
                          await productService.createProduct(
                            Product(
                              id: 0,
                              namaProduk: nameController.text,
                              deskripsi: descriptionController.text,
                              kategori: '1',
                              harga: int.parse(priceController.text),
                            ),
                            _image,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Product added successfully'),
                          ));
                        } else {
                          await productService.updateProduct(
                            Product(
                              id: existingProduct.id,
                              namaProduk: nameController.text,
                              deskripsi: descriptionController.text,
                              kategori: '1',
                              harga: int.parse(priceController.text),
                              image: existingProduct.image,
                            ),
                            _image,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Product updated successfully'),
                          ));
                        }
                        setState(() {
                          products = productService.fetchProducts();
                        });
                        Navigator.pop(context);
                      } catch (error) {
                        print('Error: $error');
                      }
                    }
                  },
                  child: Text(
                    existingProduct == null ? 'Add' : 'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF5B4F07),
          title: Text(
            product.namaProduk,
            style: TextStyle(color: Color(0xFFF9B14F)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              product.image != null
                  ? Image.network(
                      product.image!,
                      height: 150,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: Icon(Icons.image, size: 50),
                    ),
              SizedBox(height: 10),
              Text(
                "Price: ${product.harga}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFF9B14F)),
              ),
              SizedBox(height: 10),
              Text(
                product.deskripsi,
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: Color(0xFFF9B14F)),
              ),
            ),
          ],
        );
      },
    );
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
          leading: const Icon(Icons.history),
          title: const Text('History Belanja'),
          onTap: () {
            Navigator.pop(context); // Tutup drawer
            _navigateToHistoryPage();
          },
        ),
        ListTile(
          leading: const Icon(Icons.report),
          title: const Text('Laporan Belanja'),
          onTap: () {
            Navigator.pop(context); // Tutup drawer
            _navigateToSalesPage();
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Update Password'),
          onTap: () {
            Navigator.pop(context); // Tutup drawer
            LoginPage(); // Fungsi navigasi ke halaman update password
          },
        ),
     
      ],
    ),
  );
}

  /// Fungsi untuk navigasi ke halaman update password



  /// Navigasi ke halaman History Belanja
 /// Navigasi ke halaman History Belanja
Future<void> _navigateToHistoryPage() async {
  // Ambil userId dari TokenManager
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManajemenUserPage(),
      ),
    );
  
}

Future<void> _navigateToSalesPage() async {
  // Ambil userId dari TokenManager
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalesReportPage(),
      ),
    );
  
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Manage Products'),
        backgroundColor: Color(0xFF5B4F07),
      ),
      drawer: _buildDrawer(), // Drawer muncul
      body: FutureBuilder<List<Product>>(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products found.'));
          } else {
            final data = snapshot.data!;
            return GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 0.8,
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final product = data[index];
                return Card(
                  color: Color(0xFF0D0D0D),
                  elevation: 4,
                  child: InkWell(
                    onTap: () => showProductDetails(product),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: product.image != null
                              ? Image.network(
                                  product.image!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: Icon(Icons.image, size: 50),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product.namaProduk,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF9B14F)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Price: ${product.harga}",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Color(0xFFF9B14F)),
                              onPressed: () => showAddProductDialog(existingProduct: product),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  await productService.deleteProduct(product.id);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('Product deleted successfully'),
                                  ));
                                  setState(() {
                                    products = productService.fetchProducts();
                                  });
                                } catch (error) {
                                  print('Error deleting product: $error');
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFF9B14F),
        onPressed: () => showAddProductDialog(),
        child: Icon(Icons.add, color: Color(0xFF0D0D0D)),
      ),
    );
  }
}
