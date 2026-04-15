import 'package:digital_shores/app/presentation/provider/delete_account_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  late DeleteAccountNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<DeleteAccountNotifier>(context, listen: false);
    notifier.init();
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
      appBar: AppBar(
        title: const Text('Hapus Akun'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          children: [
            const Text(
              'Anda sedang dalam proses untuk menghapus akun Anda secara permanen. Sebelum melanjutkan, kami ingin memastikan bahwa Anda menyadari konsekuensi dari tindakan ini.',
              textAlign: TextAlign.justify,
              style: kSubtitle5TextStyle,
            ),
            const SizedBox(height: 16),
            // TextInputColumn(
            //   text: 'PIN',
            //   autoFocus: true,
            //   controller: passwordController,
            //   formKey: formKey,
            //   hintText: 'Masukkan PIN',
            //   isPassword: true,
            //   validator: (value) => value.isEmpty,
            //   validatorText: 'PIN harus diisi',
            //   onComplete: () async => onSubmit(),
            // ),
            const SizedBox(height: kDefaultPadding),
            Consumer<DeleteAccountNotifier>(
              builder: (context, value, child) {
                final state = value.registerPhoneNumberState;
                if (state.stateLoading()) {
                  return const LoadingIndicator(red: true);
                } else if (state.stateError()) {
                  CustomSnackbar.alert(context, state.failure!.message);
                } else if (state.stateSuccess()) {
                  Future.microtask(() => router.push('/profile/delete/otp'));
                  return const LoadingIndicator(red: true);
                }
                return PrimaryElevatedButton(
                  text: 'Kirim OTP',
                  red: true,
                  onPressed: notifier.registerPhoneNumber,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
