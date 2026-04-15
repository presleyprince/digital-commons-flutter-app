// ignore_for_file: use_build_context_synchronously
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/app/presentation/widgets/global/screen_dialog_loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/app/presentation/widgets/input/dropdown_input_column.dart';
import 'package:digital_shores/app/presentation/widgets/input/text_input_column.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:digital_shores/core/utils/parse_occupation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late AuthNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<AuthNotifier>(context, listen: false);
    notifier.initForm();
    super.initState();
  }

  @override
  void dispose() {
    notifier.disposeForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(builder: (context, value, child) {
      final updateImageState = value.updateProfileImageState;
      if (updateImageState.stateError()) {
        CustomSnackbar.alert(context, updateImageState.failure!.message);
      } else if (updateImageState.stateSuccess()) {
        CustomSnackbar.success(context, 'Berhasil mengubah foto profil');
      }
      return Stack(
        children: [
          Scaffold(
            appBar: const TransparentAppBar(title: 'Edit Profil'),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Form(
                  key: notifier.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextInputColumn(
                        text: 'Nama Lengkap',
                        controller: notifier.fullNameController,
                        formKey: notifier.formKey,
                        hintText: 'Masukkan nama lengkap Anda',
                        validator: (value) => value.isEmpty,
                        validatorText: 'Nama lengkap tidak boleh kosong',
                        arterisk: true,
                      ),
                      // TextInputColumn(
                      //   text: 'Nomor Handphone',
                      //   controller: notifier.phoneNumberController,
                      //   formKey: notifier.formKey,
                      //   hintText: 'Masukkan nomor handphone Anda',
                      //   validator: (value) => value.isEmpty,
                      //   validatorText: 'Nomor handphone tidak boleh kosong',
                      //   arterisk: true,
                      //   number: true,
                      // ),
                      DropdownInputColumn(
                        text: 'Pekerjaan',
                        notifier: notifier.occupationNotifier,
                        formKey: notifier.formKey,
                        itemBuilder: kOccupation
                            .map(
                              (e) => DropdownMenuItem(
                                value: ParseOccupation.toEnum(e),
                                child: Text(e),
                              ),
                            )
                            .toList(),
                        isExpanded: true,
                        hint: 'Pilih pekerjaan Anda',
                      ),
                      TextInputColumn(
                        text: 'Alamat',
                        controller: notifier.addressController,
                        formKey: notifier.formKey,
                        hintText: 'Masukkan alamat Anda',
                      ),
                      TextInputColumn(
                        text: 'Nama Kelompok Tani/Nelayan',
                        controller: notifier.groupNameController,
                        formKey: notifier.formKey,
                        hintText: 'Masukkan nama kelompok Anda',
                      ),
                      TextInputColumn(
                        text: 'Nama Penyuluh',
                        controller: notifier.instructorNameController,
                        formKey: notifier.formKey,
                        hintText: 'Masukkan nama penyuluh Anda',
                        onComplete: notifier.updateProfile,
                      ),
                      Consumer<AuthNotifier>(builder: (context, value, child) {
                        final state = notifier.updateProfileState;
                        if (state.stateLoading()) {
                          return const LoadingIndicator();
                        } else if (state.stateSuccess()) {
                          CustomSnackbar.success(context, 'Berhasil mengubah profil');
                        } else if (state.stateError()) {
                          CustomSnackbar.alert(context, state.failure!.message);
                        }
                        return PrimaryElevatedButton(
                          text: 'Simpan',
                          onPressed: notifier.updateProfile,
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (updateImageState.stateLoading()) const ScreenDialogLoadingIndicator(),
        ],
      );
    });
  }
}
