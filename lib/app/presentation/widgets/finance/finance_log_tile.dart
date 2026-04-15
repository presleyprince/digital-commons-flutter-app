// ignore_for_file: use_build_context_synchronously

import 'package:digital_shores/app/domain/entities/finance_log.dart';
import 'package:digital_shores/app/presentation/provider/finance_history_notifier.dart';
import 'package:digital_shores/app/presentation/provider/finance_notifier.dart';
import 'package:digital_shores/app/presentation/provider/i_finance_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/currency_format.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:digital_shores/core/utils/notifier_state.dart';
import 'package:digital_shores/core/utils/parse_date.dart';
import 'package:digital_shores/core/utils/parse_finance_category.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FinanceLogTile extends StatelessWidget {
  const FinanceLogTile({
    super.key,
    required this.data,
    required this.notifier,
    this.historyPage = false,
  });

  final FinanceLog data;
  final IFinanceNotifier notifier;
  final bool historyPage;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(data.description)),
            SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: data.category == FinanceLogCategory.expense
                    ? kRedColor
                    : data.category == FinanceLogCategory.income
                        ? kGreenColor
                        : kYellowColor,
              ),
              child: Text(
                CurrencyFormat.format(data.amount),
                style: kTitle7TextStyle.copyWith(color: color.surface),
              ),
            ),
            SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                if (historyPage) {
                  router.push('/home/my-finance-history/edit/${data.id}');
                } else {
                  notifier.setSelectedData(data);
                }
              },
              child: Image.asset(
                R.ASSETS_ICONS_EDIT_PNG,
                color: color.primary,
                width: 24,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              ParseDate.toText(data.date),
              style: TextStyle(
                color: kGreyColor,
              ),
            ),
            Spacer(),
            Text(ParseFinanceCategory.toText(data.category)),
            SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    // Get the appropriate notifier state and deleteData function
                    late NotifierState state;
                    late Future<void> Function(FinanceLog finance) deleteData;

                    if (notifier is FinanceNotifier) {
                      state = (notifier as FinanceNotifier).deleteDataState;
                      deleteData = (notifier as FinanceNotifier).deleteData;
                    } else {
                      state = (notifier as FinanceHistoryNotifier).deleteDataState;
                      deleteData = (notifier as FinanceHistoryNotifier).deleteData;
                    }

                    return StatefulBuilder(
                      builder: (context, setState) {
                        // Handle state changes
                        if (state.stateError()) {
                          // Schedule in next frame to avoid build issues
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            CustomSnackbar.alert(dialogContext, state.failure!.message);
                            Navigator.of(dialogContext).pop(); // Close dialog on error
                          });
                        } else if (state.stateSuccess()) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            // Update today data if delete data from history page and the data date is today
                            if (historyPage && ParseDate.isToday(data.date)) {
                              Provider.of<FinanceNotifier>(dialogContext, listen: false)
                                  .getTodayData();
                            }
                            CustomSnackbar.success(dialogContext, 'Berhasil menghapus data');
                            Navigator.of(dialogContext).pop(); // Close dialog on success
                          });
                        }

                        if (!state.stateInitial()) {
                          return const LoadingIndicator();
                        }

                        return AlertDialog(
                          title: const Text('Hapus Data'),
                          content: Text(
                            'Data transaksi ${data.description} akan dihapus\nApakah Anda yakin?',
                            textAlign: TextAlign.start,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Call deleteData and then use a listener to update dialog
                                await deleteData(data);

                                // Check if the dialog is still open before updating state
                                if (context.mounted) {
                                  setState(() {
                                    // Just trigger a rebuild to reflect the new state
                                    if (notifier is FinanceNotifier) {
                                      state = (notifier as FinanceNotifier).deleteDataState;
                                    } else {
                                      state = (notifier as FinanceHistoryNotifier).deleteDataState;
                                    }
                                  });
                                }
                              },
                              child: const Text('Hapus'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              child: Image.asset(
                R.ASSETS_ICONS_DELETE_PNG,
                color: kRedColor,
                width: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
