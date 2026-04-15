import 'package:intl/intl.dart';

class ParseDate {
  static DateTime fromString(String date) {
    return DateTime.parse(date);
  }

  static String toText(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  static String toTextHour(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }
}
