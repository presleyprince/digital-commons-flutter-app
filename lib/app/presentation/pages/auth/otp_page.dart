// ignore_for_file: use_build_context_synchronously

import 'package:digital_shores/app/presentation/provider/administration_notifier.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/provider/finance_notifier.dart';
import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/provider/otp_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/auth/otp_form.dart';
import 'package:digital_shores/app/presentation/widgets/auth/otp_text.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late OtpNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<OtpNotifier>(context, listen: false);
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
              child: SingleChildScrollView( //fix overflow
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
                  // the otp form here
                  // GestureDetector(
                  //   onTap: () {
                  //     notifier.otpFocusNode.unfocus();
                  //     Future.delayed(
                  //         Duration(milliseconds: 500), () => notifier.otpFocusNode.requestFocus());
                  //   },
                  //   child: OtpForm(),
                  // ),
                  Form(
                    key: notifier.otpFormKey,
                    child: OtpForm(),
                  ),
                  const SizedBox(height: kDefaultPadding),
                  OtpText(),
                  const SizedBox(height: kDefaultPadding),
                  Consumer<OtpNotifier>(
                    builder: (context, notifier, widgets) {
                      final state = notifier.verifyOtpState;
                      if (state.stateLoading()) {
                        return const LoadingIndicator();
                      } else if (state.stateSuccess()) {
                        Provider.of<AuthNotifier>(context, listen: false).setUser(state.value!);
                        final userId =
                            Provider.of<AuthNotifier>(context, listen: false).userData!.id;
                        CustomSnackbar.success(context, 'Berhasil masuk');
                        Future.microtask(() {
                          Provider.of<FinanceNotifier>(context, listen: false).fetchData(userId);
                          Provider.of<AdministrationNotifier>(context, listen: false)
                              .fetchData(userId);
                          Provider.of<InformationNotifier>(context, listen: false).fetchData();
                        });
                        Future.microtask(() => router.go('/home'));
                        return const LoadingIndicator();
                      } else if (state.stateError()) {
                        CustomSnackbar.alert(context, state.failure!.message);
                      }

                      return PrimaryElevatedButton(
                        text: 'Verifikasi',
                        onPressed: notifier.sentOtp,
                      );
                    },
                  
                  ),
                ],
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
