import 'package:digital_shores/app/presentation/provider/otp_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/global/loading_indicator.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/utils/custom_snackbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtpText extends StatelessWidget {
  const OtpText({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Consumer<OtpNotifier>(builder: (context, notifier, child) {
      final state = notifier.resendOtpState;

      if (state.stateLoading()) {
        return const LoadingIndicator();
      } else if (state.stateError()) {
        CustomSnackbar.alert(context, state.failure!.message);
      } else if (state.stateSuccess()) {
        CustomSnackbar.success(context, 'Kode OTP berhasil dikirim ulang');
      }
      return ValueListenableBuilder(
        valueListenable: notifier.resendOtpTime,
        builder: (context, int? value, child) {
          return RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Belum menerima kode OTP? ',
                  style: kBodyTextStyle.copyWith(
                    color: color.onSurface,
                  ),
                ),
                TextSpan(
                  text: 'Kirim Ulang${value != null ? '(${value}d)' : ''}',
                  style: kBodyTextStyle.copyWith(
                    color: color.primary,
                    fontWeight: kFontweightBold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => value == null ? notifier.resendOtp() : null,
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
