// lib/models/order_detail.dart

class OrderDetail {
  final int productId;
  final String productName;
  final int quantity;
  final int price;

  OrderDetail({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
  return OrderDetail(
    productId: json['product_id'] ?? 0, // Default ke 0 jika null
    productName: json['nama_produk'] ?? 'Unknown', // Default ke 'Unknown' jika null
    quantity: json['quantity'] ?? 0, // Default ke 0 jika null
    price: json['price'] ?? 0, // Default ke 0 jika null
  );
}


}
