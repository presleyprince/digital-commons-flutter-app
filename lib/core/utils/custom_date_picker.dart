import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class CustomDatePicker {
  static Future<DateTime?> showCustomMonthYearPicker(BuildContext context,
      {DateTime? initialDate}) async {
    // Use initialDate if provided, otherwise use current date
    final effectiveDate = initialDate ?? DateTime.now();

    final List<String> indonesianMonths = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final color = Theme.of(context).colorScheme;

    // First, show year picker
    int? selectedYear;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(kDefaultPadding),
                topRight: Radius.circular(kDefaultPadding),
              ),
              color: color.surface,
            ),
            child: Text('Pilih Tahun'),
          ),
          titlePadding: EdgeInsets.zero,
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: 77, // 2024 to 2100
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final year = 2024 + index;
                final isSelected = effectiveDate.year == year;
                return ListTile(
                  title: Text(
                    year.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? color.onPrimary : null,
                      fontWeight: kFontweightSemiBold,
                    ),
                  ),
                  tileColor: isSelected ? color.primary : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () {
                    selectedYear = year;
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    // If year was selected, show month picker
    if (selectedYear != null) {
      int? selectedMonth;
      await showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Pilih Bulan'),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final isSelected =
                      effectiveDate.year == selectedYear && effectiveDate.month == (index + 1);
                  return InkWell(
                    onTap: () {
                      selectedMonth = index + 1;
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected ? color.primary : null,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        indonesianMonths[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? color.onPrimary : null,
                          fontWeight: kFontweightSemiBold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );

      // If both year and month were selected, return the date
      if (selectedMonth != null) {
        return DateTime(selectedYear!, selectedMonth!, 1, 0, 0, 0);
      }
    }

    return null;
  }
}
