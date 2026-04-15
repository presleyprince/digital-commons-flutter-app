import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class FilterTextBox<T> extends StatelessWidget {
  const FilterTextBox({
    super.key,
    required this.category,
    required this.text,
    required this.selectedCategory,
  });

  final T? category;
  final String text;
  final ValueNotifier<T?> selectedCategory;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => selectedCategory.value = category,
      child: ValueListenableBuilder(
        valueListenable: selectedCategory,
        builder: (context, value, child) {
          final selected = value == category;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: selected ? color.primary : kGreyColor,
            ),
            child: Text(
              text,
              style: kTitle6TextStyle.copyWith(
                color: kWhiteColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
