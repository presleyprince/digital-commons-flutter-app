import 'package:digital_shores/app/presentation/provider/finance_history_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/finance/finance_history_range_radio_button.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/custom_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinanceHistoryDateFilter extends StatelessWidget {
  const FinanceHistoryDateFilter({
    super.key,
    required this.notifier,
  });

  final FinanceHistoryNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rentang',
            style: kSubtitle3TextStyle,
          ),
          SizedBox(height: 8),
          FinanceHistoryRangeRadioButton(
            rangeController: notifier.rangeTypeController,
            value: FinanceHistoryRangeType.today,
            text: 'Hari ini',
          ),
          FinanceHistoryRangeRadioButton(
            rangeController: notifier.rangeTypeController,
            value: FinanceHistoryRangeType.thisWeek,
            text: '1 Minggu',
          ),
          FinanceHistoryRangeRadioButton(
            rangeController: notifier.rangeTypeController,
            value: FinanceHistoryRangeType.thisMonth,
            text: '1 Bulan',
          ),
          FinanceHistoryRangeRadioButton(
            rangeController: notifier.rangeTypeController,
            value: FinanceHistoryRangeType.customMonth,
            widget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Bulan',
                  style: kBodyTextStyle,
                ),
                SizedBox(height: 8),
                ValueListenableBuilder<DateTime?>(
                  valueListenable: notifier.monthFilterController,
                  builder: (context, month, child) {
                    return GestureDetector(
                      onTap: () async {
                        final selectedDate = await CustomDatePicker.showCustomMonthYearPicker(
                          context,
                          initialDate: month,
                        );
                        if (selectedDate != null) {
                          notifier.monthFilterController.value = selectedDate;
                          notifier.rangeTypeController.value = FinanceHistoryRangeType.customMonth;
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: color.primary,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 24,
                              color: color.primary,
                            ),
                            month != null
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(DateFormat('MMMM yyyy').format(month)),
                                  )
                                : SizedBox(width: kDefaultPadding),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: color.primary,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
