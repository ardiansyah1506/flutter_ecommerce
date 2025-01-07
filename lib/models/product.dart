class Product {
  final int id;
  final String namaProduk;
  final String deskripsi;
  final String? image;
  final String kategori;
  final int harga; // Tambahkan kolom harga

  Product({
    required this.id,
    required this.namaProduk,
    required this.deskripsi,
    this.image,
    required this.kategori,
    required this.harga, // Tambahkan harga di konstruktor
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['produk_id'] ?? 0,
      namaProduk: json['nama_produk'] ?? 'Unknown',
      deskripsi: json['deskripsi'] ?? 'No description',
      image: json['image'],
      kategori: json['kategori']?.toString() ?? '0',
      harga: json['harga'] as int, // Pastikan harga diambil dari JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_produk': namaProduk,
      'deskripsi': deskripsi,
      'image': image,
      'kategori': kategori,
      'harga': harga, // Pastikan harga dikirimkan dalam JSON
    };
  }
}
