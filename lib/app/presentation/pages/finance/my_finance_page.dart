import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/provider/finance_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/finance/finance_form.dart';
import 'package:digital_shores/app/presentation/widgets/finance/finance_header_button.dart';
import 'package:digital_shores/app/presentation/widgets/finance/finance_log_tile.dart';
import 'package:digital_shores/app/presentation/widgets/global/error_column_widget.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/app/presentation/widgets/global/screen_dialog_loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:digital_shores/core/utils/parse_finance_category.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyFinancePage extends StatefulWidget {
  const MyFinancePage({super.key});

  @override
  State<MyFinancePage> createState() => _MyFinancePageState();
}

class _MyFinancePageState extends State<MyFinancePage> {
  late FinanceNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<FinanceNotifier>(context, listen: false);
    notifier.initForm(null);
    notifier.getTodayData();
    super.initState();
  }

  @override
  void dispose() {
    notifier.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceNotifier>(
      builder: (context, notifier, child) {
        final getState = notifier.fetchDataState;
        final syncState = notifier.syncDataState;

        if (getState.stateError()) {
          final userId = Provider.of<AuthNotifier>(context, listen: false).userData!.id;
          return ErrorColumnWidget(
            text: getState.failure!.message,
            onPressed: () => notifier.fetchData(userId),
          );
        } else if (syncState.stateError()) {
          if (syncState.failure!.message == 'Seluruh data sudah disinkronkan') {
            CustomSnackbar.success(context, 'Seluruh data sudah disinkronkan');
          } else {
            CustomSnackbar.alert(context, syncState.failure!.message);
          }
        } else if (syncState.stateSuccess()) {
          CustomSnackbar.success(context, 'Berhasil menyinkronkan data di server');
        }

        return SafeArea(
          child: Stack(
            children: [
              ValueListenableBuilder(
                valueListenable: notifier.selectedData,
                builder: (context, selectedData, child) {
                  return Scaffold(
                    appBar: TransparentAppBar(
                      title: 'KeuanganKu',
                      onBack: selectedData != null ? notifier.clearSelectedData : null,
                      // onBack: notifier.clearSelectedData,
                    ),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                      child: Column(
                        children: [
                          if (selectedData == null) FinanceHeaderButton(notifier: notifier),
                          FinanceForm(notifier: notifier),
                          Consumer<FinanceNotifier>(
                            builder: (context, value, child) {
                              final state = notifier.addDataState;
                              if (state.stateLoading()) {
                                return const LoadingIndicator();
                              } else if (state.stateError()) {
                                CustomSnackbar.alert(context, state.failure!.message);
                              } else if (state.stateSuccess()) {
                                CustomSnackbar.success(
                                  context,
                                  'Berhasil menyimpan data',
                                );
                              }
                              return ValueListenableBuilder(
                                valueListenable: notifier.financeCategoryController,
                                builder: (context, value, child) {
                                  return PrimaryElevatedButton(
                                    text: selectedData != null
                                        ? 'Simpan'
                                        : 'Tambah ${ParseFinanceCategory.toText(value)}',
                                    onPressed: notifier.addData,
                                  );
                                },
                              );
                            },
                          ),
                          SizedBox(height: 24),
                          // hide list when editing
                          if (selectedData == null)
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
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (getState.stateLoading() || syncState.stateLoading())
                const ScreenDialogLoadingIndicator(),
            ],
          ),
        );
      },
    );
  }
}
