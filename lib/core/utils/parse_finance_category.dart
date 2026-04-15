import 'package:digital_shores/core/enums.dart';

class ParseFinanceCategory {
  static String toText(FinanceLogCategory? category) {
    switch (category) {
      case FinanceLogCategory.income:
        return 'Pendapatan';
      case FinanceLogCategory.expense:
        return 'Pembelian';
      case FinanceLogCategory.loan:
        return 'Pinjaman';
      default:
        return 'Semua';
    }
  }

  static FinanceLogCategory? fromText(String text) {
    switch (text) {
      case 'Pendapatan':
        return FinanceLogCategory.income;
      case 'Pembelian':
        return FinanceLogCategory.expense;
      case 'Pinjaman':
        return FinanceLogCategory.loan;
      default:
        return null;
    }
  }
}
