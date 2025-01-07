import 'package:flutter/material.dart';
import 'package:frontend/services/order_service.dart';
import 'package:frontend/models/order.dart';

class HistoryBelanjaPage extends StatefulWidget {
  final int userId;

  const HistoryBelanjaPage({Key? key, required this.userId}) : super(key: key);

  @override
  _HistoryBelanjaPageState createState() => _HistoryBelanjaPageState();
}

class _HistoryBelanjaPageState extends State<HistoryBelanjaPage> {
  final OrderService _orderService = OrderService();
  late Future<List<Order>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = _orderService.getUserOrders(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Belanja'),
        backgroundColor: const Color(0xFF5B4F07), // Warna cokelat gelap
      ),
      body: FutureBuilder<List<Order>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat pesanan'),
            );
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 4, // Memberikan shadow pada card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: const Color(0xFFF9E4B7), // Warna cokelat muda
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${order.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF5B4F07), // Warna cokelat gelap
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: Color(0xFF5B4F07),
                              ),
                              onPressed: () {
                                _showOrderDetails(order);
                              },
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFF5B4F07)), // Garis pembatas
                        Text(
                          'Provinsi: ${order.province}',
                          style: const TextStyle(
                            color: Color(0xFF5B4F07),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Kota: ${order.city}',
                          style: const TextStyle(
                            color: Color(0xFF5B4F07),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Alamat: ${order.address}',
                          style: const TextStyle(
                            color: Color(0xFF5B4F07),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Ongkir: Rp ${order.shippingCost}',
                          style: const TextStyle(
                            color: Color(0xFF5B4F07),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Total: Rp ${order.totalPrice}',
                          style: const TextStyle(
                            color: Color(0xFF5B4F07),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  /// Menampilkan dialog popup dengan detail produk
  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Detail Order #${order.id}',
            style: const TextStyle(color: Color(0xFF5B4F07)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: order.orderDetails.map((detail) {
                return ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: Text(detail.productName),
                  subtitle: Text(
                    'Qty: ${detail.quantity} | Harga: Rp ${detail.price}',
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Tutup",
                style: TextStyle(color: Color(0xFF5B4F07)),
              ),
            ),
          ],
        );
      },
    );
  }
}
