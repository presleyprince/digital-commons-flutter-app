import 'package:digital_shores/app/presentation/provider/finance_history_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/finance/finance_history_date_filter.dart';
import 'package:digital_shores/app/presentation/widgets/finance/finance_history_filter.dart';
import 'package:digital_shores/app/presentation/widgets/finance/finance_log_tile.dart';
import 'package:digital_shores/app/presentation/widgets/finance/finance_totals_row.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyFinanceHistoryPage extends StatefulWidget {
  const MyFinanceHistoryPage({super.key});

  @override
  State<MyFinanceHistoryPage> createState() => _MyFinanceHistoryPageState();
}

class _MyFinanceHistoryPageState extends State<MyFinanceHistoryPage> {
  late FinanceHistoryNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<FinanceHistoryNotifier>(context, listen: false);
    notifier.init();
    notifier.setFilterToToday();
    super.initState();
  }

  @override
  void dispose() {
    notifier.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TransparentAppBar(
        title: 'Riwayat Transaksi',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FinanceHistoryFilter(notifier: notifier),
              FinanceHistoryDateFilter(notifier: notifier),
              FinanceTotalsRow(notifier: notifier),
              ValueListenableBuilder(
                valueListenable: notifier.financeList,
                builder: (context, value, child) => ListView.separated(
                  itemCount: notifier.financeList.value.length,
                  padding: EdgeInsets.only(bottom: kDefaultPadding),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return FinanceLogTile(
                      data: notifier.financeList.value[index],
                      notifier: notifier,
                      historyPage: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
