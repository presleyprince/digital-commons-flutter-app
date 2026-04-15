import 'package:digital_shores/app/presentation/provider/finance_history_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/finance/finance_total_tile.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:flutter/material.dart';

class FinanceTotalsRow extends StatelessWidget {
  const FinanceTotalsRow({
    super.key,
    required this.notifier,
  });

  final FinanceHistoryNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Center(
        child: ValueListenableBuilder(
          valueListenable: notifier.financeList,
          builder: (context, value, child) {
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FinanceTotalTile(
                  category: FinanceLogCategory.income,
                  total: notifier.incomeTotal!,
                ),
                FinanceTotalTile(
                  category: FinanceLogCategory.expense,
                  total: notifier.expenseTotal!,
                ),
                FinanceTotalTile(
                  category: FinanceLogCategory.loan,
                  total: notifier.loanTotal!,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
