// ignore_for_file: use_build_context_synchronously

import 'package:digital_shores/app/presentation/provider/add_information_notifier.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/app/presentation/widgets/information/information_image_input.dart';
import 'package:digital_shores/app/presentation/widgets/input/date_input_column.dart';
import 'package:digital_shores/app/presentation/widgets/input/text_input_column.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:digital_shores/core/utils/path_guard.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

class AddInformationPage extends StatefulWidget {
  const AddInformationPage({super.key});

  @override
  State<AddInformationPage> createState() => _AddInformationPageState();
}

class _AddInformationPageState extends State<AddInformationPage> {
  late AddInformationNotifier notifier;

  @override
  void initState() {
   PathGuard.adminGuard(context); 
    notifier = Provider.of<AddInformationNotifier>(context, listen: false);
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
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: TransparentAppBar(
        title: 'Sebarkan Informasi',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
          child: Form(
            key: notifier.formKey,
            child: Column(
              children: [
                ValueListenableBuilder(
                  valueListenable: notifier.categoryController,
                  builder: (context, value, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kategori',
                          style: kTitle6TextStyle,
                        ),
                        const SizedBox(height: 8),
                        ...InformationCategory.values.map(
                          (category) {
                            return GestureDetector(
                              onTap: () => notifier.setCategory(category),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
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
                                            color: value == category
                                                ? color.primary
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      category.label,
                                      style: kBodyTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextInputColumn(
                  text: 'Judul Berita',
                  controller: notifier.titleController,
                  hintText: 'Masukkan judul berita yang akan dibagikan',
                  formKey: notifier.formKey,
                  validator: (value) => value.isEmpty,
                  validatorText: 'Judul berita harus diisi',
                ),
                DateInputColumn(
                  text: 'Tanggal Penerbitan',
                  notifier: notifier.createdAtController,
                  formKey: notifier.formKey,
                  validator: (value) => value == null,
                  validatorText: 'Tanggal penerbitan harus diisi',
                ),
                TextInputColumn(
                  text: 'Nama Sumber Informasi/Penulis Berita',
                  controller: notifier.authorController,
                  formKey: notifier.formKey,
                  hintText: 'Masukkan nama sumber informasi atau penulis berita',
                  validator: (value) => value.isEmpty,
                  validatorText: 'Nama sumber informasi/penulis berita harus diisi',
                ),
                InformationImageInput(notifier: notifier),
                FormField(
                  enabled: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (notifier.contentController.document.toPlainText().trim().isEmpty) {
                      return 'Konten harus diisi';
                    }
                    return null;
                  },
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Konten',
                          style: kTitle5TextStyle,
                        ),
                        const SizedBox(height: 8),
                        QuillSimpleToolbar(
                          controller: notifier.contentController,
                          config: const QuillSimpleToolbarConfig(
                            showBoldButton: true,
                            showItalicButton: true,
                            showUnderLineButton: true,
                            showListNumbers: true,
                            showListBullets: true,
                            showLink: true,
                            showAlignmentButtons: true,
                            showUndo: true,
                            showRedo: true,
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(
                            minHeight: 200,
                            // maxHeight: MediaQuery.of(context).size.height * 0.4, // Adjust as needed
                          ),
                          child: QuillEditor.basic(
                            controller: notifier.contentController,
                          )
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              field.errorText!,
                              style: const TextStyle(
                                fontStyle: FontStyle.normal,
                                fontSize: 13,
                                color: kDefaultErrorColor,
                                height: 0.5,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Consumer<AddInformationNotifier>(builder: (context, notifier, child) {
                  final addState = notifier.addDataState;
                  final updateState = notifier.updateDataState;

                  if (addState.stateLoading() || updateState.stateLoading()) {
                    return const LoadingIndicator();
                  } else if (addState.stateError()) {
                    CustomSnackbar.alert(context, addState.failure!.message);
                  } else if (updateState.stateError()) {
                    CustomSnackbar.alert(context, updateState.failure!.message);
                  } else if (addState.stateSuccess() || updateState.stateSuccess()) {
                    if (notifier.isEdit()) {
                      Provider.of<InformationNotifier>(context, listen: false)
                          .updateData(updateState.value!);
                    } else {
                      Provider.of<InformationNotifier>(context, listen: false)
                          .addData(addState.value!);
                    }
                    CustomSnackbar.success(
                      context,
                      'Berhasil menyimpan data',
                    );
                    Future.microtask(() {
                      if (router.canPop()) {
                        router.pop();
                      }
                    });
                  }

                  return PrimaryElevatedButton(
                    text: 'Tambah',
                    onPressed: () {
                      final authorId =
                          Provider.of<AuthNotifier>(context, listen: false).userData?.id ?? ''; // fallback to the empty string if userdata is null to avoid hardcoded test values from the firebase
                      if (notifier.isEdit()) {
                        notifier.updateInformation(authorId);
                      } else {
                        notifier.addInformation(authorId);
                      }
                    },
                  );
                }),
                const SizedBox(height: kDefaultPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
