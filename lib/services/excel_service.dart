import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import '../models/japanese_word.dart';

class ExcelService {
  static Future<List<JapaneseWord>> loadJapaneseWords() async {
    try {
      // Load the Excel file from assets
      final ByteData data = await rootBundle.load('assets/japanese_words.xlsx');
      final Uint8List bytes = data.buffer.asUint8List();
      
      // Parse the Excel file
      final Excel excel = Excel.decodeBytes(bytes);
      
      List<JapaneseWord> words = [];
      
      // Get the first sheet
      final sheet = excel.tables.values.first;
      
      // Skip header row (if exists) and process data rows
      for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
        final row = sheet.rows[rowIndex];
        
        // Skip empty rows
        if (row.isEmpty) continue;
        
        // Convert row to list of strings
        final List<dynamic> rowData = row.map((cell) => cell?.value).toList();
        
        // Skip rows with empty first column
        if (rowData.isEmpty || rowData[0] == null || rowData[0].toString().trim().isEmpty) {
          continue;
        }
        
        // Create JapaneseWord object
        final word = JapaneseWord.fromExcelRow(rowData);
        words.add(word);
      }
      
      return words;
    } catch (e) {
      print('Error loading Japanese words: $e');
      return [];
    }
  }
}
