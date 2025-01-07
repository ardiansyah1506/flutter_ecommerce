import 'package:flutter/material.dart';
import 'package:frontend/services/excel_service.dart';
import 'package:frontend/services/order_service.dart';
import 'package:frontend/services/pdf_service.dart';

class TransactionReportPage extends StatefulWidget {
  @override
  _TransactionReportPageState createState() => _TransactionReportPageState();
}

class _TransactionReportPageState extends State<TransactionReportPage> {
  final OrderService _orderService = OrderService();
  late Future<List<Map<String, dynamic>>> _futureTransactionReport;

  @override
  void initState() {
    super.initState();
    _futureTransactionReport = _orderService.getTransactionReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Transaksi'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final transactions = await _futureTransactionReport;
              await generatePdfReport(
                title: 'Laporan Transaksi',
                data: transactions,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.file_present),
            onPressed: () async {
              final transactions = await _futureTransactionReport;
              await generateExcelReport(
                fileName: 'Laporan_Transaksi',
                data: transactions,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureTransactionReport,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tidak ada data transaksi.'),
            );
          } else {
            final transactions = snapshot.data!;
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Order #${transaction['order_id']}'),
                    subtitle: Text(
                      'Nama Customer: ${transaction['customer_name']}\n'
                      'Alamat: ${transaction['address']}\n'
                      'Total Harga: Rp ${transaction['total_price']}\n'
                      'Tanggal: ${transaction['order_date']}',
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
}
