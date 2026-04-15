import 'package:digital_shores/app/presentation/provider/finance_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';

class FinanceHeaderButton extends StatelessWidget {
  const FinanceHeaderButton({
    super.key,
    required this.notifier,
  });

  final FinanceNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Row(
        children: [
          Expanded(
            child: PrimaryElevatedButton(
              text: 'Segarkan',
              image: R.ASSETS_ICONS_SYNC_PNG,
              onPressed: notifier.syncFinanceLogs,
            ),
          ),
          SizedBox(width: 26),
          Expanded(
            child: PrimaryElevatedButton(
              text: 'Riwayat',
              image: R.ASSETS_ICONS_HISTORY_PNG,
              onPressed: () => router.push('/home/my-finance-history'),
            ),
          ),
        ],
      ),
    );
  }
}
