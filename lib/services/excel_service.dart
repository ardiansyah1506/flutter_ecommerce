import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

Future<void> generateExcelReport({
  required String fileName,
  required List<Map<String, dynamic>> data,
}) async {
  final excel = Excel.createExcel(); // Membuat file Excel baru
  final sheet = excel['Sheet1']; // Membuat sheet baru

  // Tambahkan header ke sheet
  if (data.isNotEmpty) {
    final headerRow = data.first.keys.toList();
    for (var i = 0; i < headerRow.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
          .value = headerRow[i] as CellValue?; // Header ditambahkan sebagai String
    }
  }

  // Tambahkan data ke sheet
  for (var rowIndex = 0; rowIndex < data.length; rowIndex++) {
    final row = data[rowIndex].values.toList();
    for (var colIndex = 0; colIndex < row.length; colIndex++) {
      final cellValue = row[colIndex]?.toString() ?? ''; // Pastikan nilai dalam bentuk String
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex + 1))
          .value = cellValue as CellValue?; // Masukkan data sebagai String
    }
  }

  // Simpan file Excel
  final directory = await getApplicationDocumentsDirectory(); // Direktori aplikasi
  final filePath = '${directory.path}/$fileName.xlsx'; // Nama file
  final file = File(filePath);

  // Tulis file ke sistem
  await file.writeAsBytes(excel.encode()!);

  // Konfirmasi kepada pengguna
  print('File Excel berhasil disimpan di $filePath');
}
