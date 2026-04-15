import 'package:digital_shores/app/presentation/provider/administration_notifier.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/administration/administration_action_button.dart';
import 'package:digital_shores/app/presentation/widgets/administration/administration_document_container.dart';
import 'package:digital_shores/app/presentation/widgets/administration/administration_document_type_filter.dart';
import 'package:digital_shores/app/presentation/widgets/administration/administration_no_data_column.dart';
import 'package:digital_shores/app/presentation/widgets/administration/administration_search_box.dart';
import 'package:digital_shores/app/presentation/widgets/global/error_column_widget.dart';
import 'package:digital_shores/app/presentation/widgets/global/screen_dialog_loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdministrationPage extends StatefulWidget {
  const AdministrationPage({super.key});

  @override
  State<AdministrationPage> createState() => _AdministrationPageState();
}

class _AdministrationPageState extends State<AdministrationPage> {
  late AdministrationNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<AdministrationNotifier>(context, listen: false);
    notifier.initFilter();
    super.initState();
  }

  @override
  void dispose() {
    notifier.resetFilter();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdministrationNotifier>(
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

        return Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: TransparentAppBar(
                title: 'Berkas Administrasi',
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdministrationDocumentTypeFilter(notifier: notifier),
                      AdministrationSearchBox(notifier: notifier),
                      Expanded(
                        child: notifier.dataEmpty()
                            ? AdministrationNoDataColumn()
                            : SingleChildScrollView(
                                child: Column(
                                  children: [
                                    AdministrationActionButton(),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: notifier.documents.value.length,
                                      itemBuilder: (context, index) {
                                        final data = notifier.documents.value[index];
                                        return AdministrationDocumentContainer(data: data);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (getState.stateLoading() || syncState.stateLoading())
              const ScreenDialogLoadingIndicator(),
          ],
        );
      },
    );
  }
}
