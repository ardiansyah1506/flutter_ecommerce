import 'package:flutter/material.dart';
import 'package:frontend/models/order.dart';
import 'package:intl/intl.dart';

class DetailHistoryPage extends StatelessWidget {
  final Order order;

  const DetailHistoryPage({Key? key, required this.order}) : super(key: key);
    String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan: ${order.id}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Pesanan:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Order ID: ${order.id}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text('Tanggal Pesanan: ${_formatDate(order.orderDate)}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text('Provinsi: ${order.province}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text('Kota: ${order.city}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text('Alamat: ${order.address}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text('Ongkir: Rp ${order.shippingCost}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text('Total Harga: Rp ${order.totalPrice}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(height: 16, thickness: 2),

              const Text(
                'Detail Produk:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...order.orderDetails.map(
                (detail) => Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nama Produk: ${detail.productName}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('Jumlah: ${detail.quantity}', style: const TextStyle(fontSize: 16)),
                        Text('Harga Satuan: Rp ${detail.price}',
                            style: const TextStyle(fontSize: 16)),
                        Text(
                          'Subtotal: Rp ${detail.quantity * detail.price}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(height: 16, thickness: 2),

              const Text(
                'Bukti Pembayaran:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (order.paymentProof != null && order.paymentProof!.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      order.paymentProof!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text('Gagal memuat gambar'),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                )
              else
                const Text('Bukti pembayaran tidak tersedia.'),
            ],
          ),
        ),
      ),
    );
  }
}