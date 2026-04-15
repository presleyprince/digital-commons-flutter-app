// ignore_for_file: use_build_context_synchronously

import 'package:digital_shores/app/presentation/provider/otp_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/digital_shores_introduction_column.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/app/presentation/widgets/global/need_help_card.dart';
import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:digital_shores/app/presentation/widgets/global/transparent_app_bar.dart';
import 'package:digital_shores/app/presentation/widgets/input/text_input_column.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late OtpNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<OtpNotifier>(context, listen: false);
    notifier.init();
    super.initState();
  }

  @override
  void dispose() {
    // notifier.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const TransparentAppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36),
                        child: Form(
                          key: notifier.formKey,
                          child: Column(
                            children: [
                              DigitalShoresIntroductionColumn(),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Masuk',
                                  style: kTitle5TextStyle.copyWith(
                                    color: color.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextInputColumn(
                                text: 'Nomor Handphone',
                                controller: notifier.phoneNumberController,
                                formKey: notifier.formKey,
                                prefix: Container(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  width: 40,
                                  child: Center(
                                    child: Text(
                                      '+62',
                                      textAlign: TextAlign.center,
                                      style: kSubtitle5TextStyle,
                                    ),
                                  ),
                                ),
                                number: true,
                                titlePrimary: true,
                                hintText: 'Masukkan nomor handphone Anda',
                                validator: (value) => value.isEmpty,
                                validatorText: 'Nomor handphone harus diisi',
                                onComplete: notifier.registerPhoneNumber,
                              ),
                              // TextInputColumn(
                              //   text: 'PIN',
                              //   controller: notifier.pinController,
                              //   isPassword: true,
                              //   titlePrimary: true,
                              //   formKey: notifier.formKey,
                              //   hintText: 'Masukkan PIN Anda',
                              //   onComplete: notifier.login,
                              //   validator: (value) => value.isEmpty,
                              //   validatorText: 'PIN harus diisi',
                              // ),
                              Consumer<OtpNotifier>(
                                builder: (context, notifier, widgets) {
                                  final state = notifier.registerPhoneNumberState;
                                  if (state.stateLoading()) {
                                    return const LoadingIndicator();
                                  } else if (state.stateSuccess()) {
                                    Future.microtask(() => router.go('/onboarding/otp'));
                                    return const LoadingIndicator();
                                  } else if (state.stateError()) {
                                    CustomSnackbar.alert(context, state.failure!.message);
                                  }

                                  return PrimaryElevatedButton(
                                    text: 'Masuk',
                                    onPressed: notifier.registerPhoneNumber,
                                  );
                                },
                              ),
                              const SizedBox(height: kDefaultPadding),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Belum memiliki akun? ',
                                      style: kBodyTextStyle.copyWith(
                                        color: color.onSurface,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Daftar',
                                      style: kBodyTextStyle.copyWith(
                                        color: color.primary,
                                        fontWeight: kFontweightBold,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => router.go('/onboarding/signup'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: kDefaultPadding),
                              // RichText(
                              //   textAlign: TextAlign.center,
                              //   text: TextSpan(
                              //     children: [
                              //       TextSpan(
                              //         text: 'Belum memiliki akun? ',
                              //         style: kBodyTextStyle.copyWith(
                              //           color: color.onSurface,
                              //         ),
                              //       ),
                              //       TextSpan(
                              //         text: 'Daftar',
                              //         style: kBodyTextStyle.copyWith(
                              //           color: color.primary,
                              //           fontWeight: kFontweightBold,
                              //         ),
                              //         recognizer: TapGestureRecognizer()
                              //           ..onTap = () => router.go('/onboarding/signup'),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const NeedHelpCard(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
