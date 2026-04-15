import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/currency_format.dart';
import 'package:digital_shores/core/utils/parse_finance_category.dart';
import 'package:flutter/material.dart';

class FinanceTotalTile extends StatelessWidget {
  const FinanceTotalTile({
    super.key,
    required this.category,
    required this.total,
  });

  final FinanceLogCategory category;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          ParseFinanceCategory.toText(category),
          style: kSubtitle3TextStyle,
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: category == FinanceLogCategory.income
                ? kGreenColor
                : category == FinanceLogCategory.expense
                    ? kRedColor
                    : kYellowColor,
            borderRadius: BorderRadius.circular(kDefaultRadius),
          ),
          child: Text(
            CurrencyFormat.format(total),
            style: kTitle6TextStyle.copyWith(
              color: kWhiteColor,
            ),
          ),
        ),
      ],
    );
  }
}
