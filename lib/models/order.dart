// lib/models/order.dart

import 'order_detail.dart';

class Order {
  final int id;
  final int userId;
  final String province;
  final String city;
  final String address;
  final int shippingCost;
  final int totalPrice;
  final String? paymentProof;
  final DateTime orderDate;
  final List<OrderDetail> orderDetails;

  Order({
    required this.id,
    required this.userId,
    required this.province,
    required this.city,
    required this.address,
    required this.shippingCost,
    required this.totalPrice,
    this.paymentProof,
    required this.orderDate,
    required this.orderDetails,
  });
factory Order.fromJson(Map<String, dynamic> json) {
  return Order(
    id: json['order_id'] ?? 0, // Default ke 0 jika null
    userId: json['user_id'] ?? 0, // Default ke 0 jika null
    province: json['province'] ?? 'Unknown', // Default ke 'Unknown' jika null
    city: json['city'] ?? 'Unknown', // Default ke 'Unknown' jika null
    address: json['address'] ?? 'Unknown', // Default ke 'Unknown' jika null
    shippingCost: json['shipping_cost'] ?? 0, // Default ke 0 jika null
    totalPrice: json['total_price'] ?? 0, // Default ke 0 jika null
    paymentProof: json['payment_proof'], // Tetap nullable
    orderDate: json['order_date'] != null
        ? DateTime.parse(json['order_date'])
        : DateTime.now(), // Default ke waktu sekarang jika null
    orderDetails: (json['details'] as List<dynamic>)
        .map((detailJson) => OrderDetail.fromJson(detailJson))
        .toList(),
  );
}

}