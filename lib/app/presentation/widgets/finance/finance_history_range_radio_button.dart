import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:flutter/material.dart';

class FinanceHistoryRangeRadioButton extends StatelessWidget {
  const FinanceHistoryRangeRadioButton({
    super.key,
    required this.rangeController,
    required this.value,
    this.text,
    this.widget,
  });

  final ValueNotifier<FinanceHistoryRangeType> rangeController;
  final FinanceHistoryRangeType value;
  final String? text;
  final Widget? widget;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ValueListenableBuilder(
          valueListenable: rangeController,
          builder: (context, range, child) {
            return GestureDetector(
              onTap: () {
                if (widget != null) {
                  return;
                }
                rangeController.value = value;
              },
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.primary,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              value == rangeController.value ? color.primary : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  text != null
                      ? Text(
                          text!,
                          style: kBodyTextStyle,
                        )
                      : widget!,
                ],
              ),
            );
          }),
    );
  }
}
