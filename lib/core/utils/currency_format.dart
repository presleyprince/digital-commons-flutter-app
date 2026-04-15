import 'package:intl/intl.dart';

class CurrencyFormat {
  static String format(int value) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(value);
  }

  static int getCurrencyValue(String text) {
    // Remove all non-digit characters
    final numericString = text.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(numericString) ?? 0;
  }
}
