// ignore_for_file: use_build_context_synchronously

import 'package:digital_shores/app/presentation/provider/administration_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/administration/administration_document_requirements_check_box.dart';
import 'package:digital_shores/app/presentation/widgets/administration/animated_image_grid.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/app/presentation/widgets/input/dropdown_input_column.dart';
import 'package:digital_shores/app/presentation/widgets/input/text_input_column.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddAdministrationPage extends StatefulWidget {
  const AddAdministrationPage({super.key});

  @override
  State<AddAdministrationPage> createState() => _AddAdministrationPageState();
}

class _AddAdministrationPageState extends State<AddAdministrationPage> {
  late AdministrationNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<AdministrationNotifier>(context, listen: false);
    notifier.initForm();
    super.initState();
  }

  @override
  void dispose() {
    notifier.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = notifier.selectedData == null ? 'Menambah Berkas' : 'Mengubah Berkas';
    return Scaffold(
      appBar: TransparentAppBar(title: title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
        child: Form(
          key: notifier.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownInputColumn(
                text: 'Jenis Berkas',
                hint: '(Select)',
                notifier: notifier.documentTypeController,
                isExpanded: true,
                itemBuilder: DocumentType.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.label),
                      ),
                    )
                    .toList(),
                validator: (value) => value == null,
                validatorText: 'Jenis berkas harus diisi',
              ),
              ValueListenableBuilder(
                valueListenable: notifier.documentTypeController,
                builder: (context, value, child) {
                  if (value != DocumentType.other &&
                      notifier.customTypeController.text.isNotEmpty) {
                    Future.microtask(() => notifier.clearCustomType());
                  }
                  return value == DocumentType.other
                      ? TextInputColumn(
                          text: 'Jenis Berkas Lainnya',
                          controller: notifier.customTypeController,
                          formKey: notifier.formKey,
                          hintText: 'Masukkan jenis berkas lainnya',
                          validator: (value) => value.isEmpty,
                          validatorText: 'Jenis berkas lainnya harus diisi',
                        )
                      : const SizedBox.shrink();
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keperluan Berkas',
                    style: kTitle6TextStyle,
                  ),
                  const SizedBox(height: 12),
                  AdministrationDocumentRequirementsCheckBox(notifier: notifier),
                ],
              ),
              AnimatedImageGrid(notifier: notifier),
              Consumer<AdministrationNotifier>(builder: (context, notifier, child) {
                final state = notifier.addDataState;
                if (state.stateLoading()) {
                  return const LoadingIndicator();
                } else if (state.stateSuccess()) {
                  CustomSnackbar.success(
                      context,
                      notifier.selectedData == null
                          ? 'Berhasil menambahkan berkas'
                          : 'Berhasil mengubah berkas');
                  Future.microtask(() => Navigator.pop(context));
                } else if (state.stateError()) {
                  CustomSnackbar.alert(context, state.failure!.message);
                }

                return PrimaryElevatedButton(
                  text: notifier.selectedData == null ? 'Tambah Berkas' : 'Ubah Berkas',
                  onPressed: notifier.addData,
                );
              }),
              const SizedBox(height: kDefaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}
