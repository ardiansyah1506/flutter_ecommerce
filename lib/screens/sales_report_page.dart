import 'package:flutter/material.dart';
import 'package:frontend/services/excel_service.dart';
import 'package:frontend/services/order_service.dart';
import 'package:frontend/services/pdf_service.dart';

class SalesReportPage extends StatefulWidget {
  @override
  _SalesReportPageState createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  final OrderService _orderService = OrderService();
  late Future<List<Map<String, dynamic>>> _futureSalesReport;

  @override
  void initState() {
    super.initState();
    _futureSalesReport = _orderService.getSalesReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final sales = await _futureSalesReport;
              await generatePdfReport(
                title: 'Laporan Penjualan',
                data: sales,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.file_present),
            onPressed: () async {
              final sales = await _futureSalesReport;
              await generateExcelReport(
                fileName: 'Laporan_Penjualan',
                data: sales,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureSalesReport,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tidak ada data penjualan.'),
            );
          } else {
            final sales = snapshot.data!;
            return ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(sale['product_name']),
                    subtitle: Text(
                      'Total Terjual: ${sale['total_quantity']} pcs\nTotal Penjualan: Rp ${sale['total_sales']}',
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
