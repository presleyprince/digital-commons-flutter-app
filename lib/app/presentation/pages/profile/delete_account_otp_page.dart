// ignore_for_file: use_build_context_synchronously

import 'package:digital_shores/app/presentation/provider/administration_notifier.dart';
import 'package:digital_shores/app/presentation/provider/delete_account_notifier.dart';
import 'package:digital_shores/app/presentation/provider/finance_notifier.dart';
import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/provider/weather_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/app/presentation/widgets/profile/delete_account_otp_form.dart';
import 'package:digital_shores/app/presentation/widgets/profile/delete_account_otp_text.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DeleteAccountOtpPage extends StatefulWidget {
  const DeleteAccountOtpPage({super.key});

  @override
  State<DeleteAccountOtpPage> createState() => _DeleteAccountOtpPageState();
}

class _DeleteAccountOtpPageState extends State<DeleteAccountOtpPage> {
  late DeleteAccountNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<DeleteAccountNotifier>(context, listen: false);
    notifier.initOtp();
    super.initState();
  }

  @override
  void dispose() {
    notifier.resetOtp();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: TransparentAppBar(),
      body: Stack(
        children: [
          // Hidden text field to capture input
          Opacity(
            opacity: 0,
            child: TextField(
              controller: notifier.otpController,
              focusNode: notifier.otpFocusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              autofocus: true,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: SingleChildScrollView(
                child: Column(
                children: [
                  Image.asset(
                    R.ASSETS_ICONS_INPUT_OTP_PNG,
                    width: 72,
                    height: 72,
                  ),
                  const SizedBox(height: kDefaultPadding),
                  Text(
                    'Masukkan Kode OTP',
                    style: kTitle6TextStyle.copyWith(color: color.primary),
                  ),
                  const SizedBox(height: kDefaultPadding),
                  Text(
                    'Kami telah mengirimkan kode OTP kepada Anda melalui SMS ke nomor ${notifier.obfuscatePhoneNumber()}',
                    style: kBodyTextStyle,
                  ),
                  const SizedBox(height: kDefaultPadding),
                  Form(
                    key: notifier.formKey,
                    child: DeleteAccountOtpForm(),
                  ),
                  const SizedBox(height: kDefaultPadding),
                  DeleteAccountOtpText(),
                  const SizedBox(height: kDefaultPadding),
                  Consumer<DeleteAccountNotifier>(
                    builder: (context, notifier, widgets) {
                      final state = notifier.verifyOtpState;
                      if (state.stateLoading()) {
                        return const LoadingIndicator(red: true);
                      } else if (state.stateSuccess()) {
                        CustomSnackbar.success(context, 'Akun berhasil dihapus');
                        Provider.of<FinanceNotifier>(context, listen: false).deleteDataList();
                        Provider.of<FinanceNotifier>(context, listen: false)
                            .clearFinanceLogsFromLocal();
                        Provider.of<AdministrationNotifier>(context, listen: false)
                            .deleteDataList();
                        Provider.of<AdministrationNotifier>(context, listen: false)
                            .clearDocumentsFromLocal();
                        Provider.of<InformationNotifier>(context, listen: false)
                            .clearInformationsFromLocal();
                        Provider.of<WeatherNotifier>(context, listen: false)
                            .clearInformationsFromLocal();
                        Future.microtask(() => router.go('/onboarding'));
                        return const LoadingIndicator(red: true);
                      } else if (state.stateError()) {
                        CustomSnackbar.alert(context, state.failure!.message);
                      }

                      return PrimaryElevatedButton(
                        text: 'Verifikasi',
                        red: true,
                        onPressed: notifier.sentOtp,
                      );
                    },
                  ),
                ],
              ),
              )
            ),
          ),
        ],
      ),
    );
  }
}
