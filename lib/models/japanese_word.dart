class JapaneseWord {
  final String firstColumn;
  final String secondColumn;
  final String thirdColumn;
  final String fourthColumn;

  JapaneseWord({
    required this.firstColumn,
    required this.secondColumn,
    required this.thirdColumn,
    required this.fourthColumn,
  });

  factory JapaneseWord.fromExcelRow(List<dynamic> row) {
    return JapaneseWord(
      firstColumn: row.isNotEmpty ? (row[0]?.toString() ?? '') : '',
      secondColumn: row.length > 1 ? (row[1]?.toString() ?? '') : '',
      thirdColumn: row.length > 2 ? (row[2]?.toString() ?? '') : '',
      fourthColumn: row.length > 3 ? (row[3]?.toString() ?? '') : '',
    );
  }
}
