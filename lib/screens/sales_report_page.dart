import 'package:flutter/material.dart';
import 'package:frontend/services/excel_service.dart';
import 'package:frontend/services/order_service.dart';
import 'package:frontend/services/pdf_service.dart';
import 'package:intl/intl.dart';


class SalesReportPage extends StatefulWidget {
  @override
  _SalesReportPageState createState() => _SalesReportPageState();
}
class _SalesReportPageState extends State<SalesReportPage> {
  final OrderService _orderService = OrderService();
  late Future<List<Map<String, dynamic>>> _futureSalesReport;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchSalesReport();
  }

  void _fetchSalesReport({DateTime? startDate, DateTime? endDate}) {
    setState(() {
      _futureSalesReport = _orderService.getSalesReport(
        startDate: startDate,
        endDate: endDate,
      );
    });
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchSalesReport(startDate: _startDate, endDate: _endDate);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date); // Format hanya Tahun-Bulan-Tanggal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final sales = await _futureSalesReport;
              await generatePdfReport(
                title: 'Laporan Penjualan',
                data: sales,
              );
            },
          ),
          IconButton(
  icon: const Icon(Icons.file_present),
  onPressed: () async {
    final sales = await _futureSalesReport;

    if (sales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diekspor')),
      );
      return;
    }

    await generateExcelReport(
      fileName: 'Laporan_Penjualan',
      data: sales,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Laporan Excel berhasil dibuat')),
    );
  },
),

        ],
      ),
      body: Column(
        children: [
          // Filter Rentang Waktu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _pickDateRange(context),
                  child: const Text('Pilih Rentang Waktu'),
                ),
                Text(
                  _startDate != null && _endDate != null
                      ? 'Dari: ${_formatDate(_startDate)} - Hingga: ${_formatDate(_endDate)}'
                      : 'Semua Data',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
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
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        border: TableBorder.all(
                          color: Colors.black,
                          width: 1,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        columnWidths: const {
                          0: FixedColumnWidth(120),
                          1: FixedColumnWidth(120),
                          2: FixedColumnWidth(150),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                            ),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Produk',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Total Terjual',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Total Penjualan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          ...sales.map(
                            (sale) => TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(sale['product_name'] ?? ''),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      sale['total_quantity']?.toString() ?? ''),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      'Rp ${sale['total_sales']?.toString() ?? '0'}'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}