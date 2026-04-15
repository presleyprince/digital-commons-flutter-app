import 'package:digital_shores/app/presentation/provider/finance_history_notifier.dart';
import 'package:digital_shores/app/presentation/provider/finance_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/finance/finance_form.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:digital_shores/core/utils/parse_date.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditFinanceHistoryPage extends StatefulWidget {
  const EditFinanceHistoryPage({
    super.key,
    required this.id,
  });

  final String id;

  @override
  State<EditFinanceHistoryPage> createState() => _EditFinanceHistoryPageState();
}

class _EditFinanceHistoryPageState extends State<EditFinanceHistoryPage> {
  late FinanceHistoryNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<FinanceHistoryNotifier>(context, listen: false);
    notifier.initForm(widget.id);
    super.initState();
  }

  @override
  void dispose() {
    notifier.resetForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TransparentAppBar(
        title: 'KeuanganKu',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Column(
            children: [
              FinanceForm(notifier: notifier),
              Consumer<FinanceHistoryNotifier>(
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
                    if (ParseDate.isToday(notifier.selectedData!.date)) {
                      Provider.of<FinanceNotifier>(context, listen: false).getTodayData();
                    }
                    Future.microtask(() => router.pop());
                  }
                  return ValueListenableBuilder(
                    valueListenable: notifier.financeCategoryController,
                    builder: (context, value, child) {
                      return PrimaryElevatedButton(
                        text: 'Simpan',
                        onPressed: notifier.addData,
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
