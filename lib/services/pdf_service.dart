
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generatePdfReport({
  required String title,
  required List<Map<String, dynamic>> data,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: data.isNotEmpty ? data.first.keys.toList() : [],
            data: data.map((row) => row.values.toList()).toList(),
            border: pw.TableBorder.all(),
          ),
        ],
      ),
    ),
  );

  // Simpan atau cetak PDF
  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
