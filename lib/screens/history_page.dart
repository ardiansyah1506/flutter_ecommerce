import 'package:flutter/material.dart';
import 'package:frontend/services/order_service.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/screens/detail_history_page.dart';

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
        title: const Text(
          'Riwayat Belanja',
          style: TextStyle(color: Color(0xFFD0C05B)),
        ),
        backgroundColor: Color.fromARGB(255, 105, 105, 105),
        iconTheme: const IconThemeData(color: Color(0xFFD0C05B)),
      ),
      body: Container(
        color: Color.fromARGB(255, 252, 252, 252),
        child: FutureBuilder<List<Order>>(
          future: _futureOrders,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD0C05B),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Color(0xFFD0C05B)),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada riwayat pesanan',
                  style: TextStyle(color: Color(0xFFD0C05B)),
                ),
              );
            } else {
              final orders = snapshot.data!;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final firstDetail = order.orderDetails.isNotEmpty
                      ? order.orderDetails.first
                      : null;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailHistoryPage(order: order),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(12),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: const Color(0xFFF9E4B7),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              firstDetail?.productName ?? 'Produk tidak tersedia',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF5B4F07),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: Rp ${order.totalPrice}',
                              style: const TextStyle(
                                color: Color(0xFF5B4F07),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}