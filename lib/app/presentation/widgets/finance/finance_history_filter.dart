import 'package:digital_shores/app/presentation/provider/finance_history_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/filter_text_box.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:flutter/material.dart';

class FinanceHistoryFilter extends StatelessWidget {
  const FinanceHistoryFilter({
    super.key,
    required this.notifier,
  });

  final FinanceHistoryNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final categories = [null, ...FinanceLogCategory.values];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter',
          style: kSubtitle3TextStyle,
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            return FilterTextBox(
              category: category,
              selectedCategory: notifier.categoryFilterController,
              text: category?.label ?? 'Semua',
            );
          }).toList(),
        ),
        SizedBox(height: kDefaultPadding),
      ],
    );
  }
}
