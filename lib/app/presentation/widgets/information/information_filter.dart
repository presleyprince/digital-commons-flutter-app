import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/filter_text_box.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:flutter/material.dart';

class InformationFilter extends StatelessWidget {
  const InformationFilter({
    super.key,
    required this.notifier,
  });

  final InformationNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final categories = [null, ...InformationCategory.values];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: kTitle4TextStyle,
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
