import 'package:digital_shores/app/presentation/provider/delete_account_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/auth/otp_number_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountOtpForm extends StatefulWidget {
  const DeleteAccountOtpForm({super.key});

  @override
  State<DeleteAccountOtpForm> createState() => _DeleteAccountOtpFormState();
}

class _DeleteAccountOtpFormState extends State<DeleteAccountOtpForm> {
  late DeleteAccountNotifier notifier;

  @override
  void initState() {
    notifier = Provider.of<DeleteAccountNotifier>(context, listen: false);
    final controller = notifier.otpController;

    notifier.otpController.addListener(() {
      setState(() {});
      if (controller.text.length == 6) {
        notifier.sentOtp();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<OtpNumberField> _buildOtpFields() {
    final List<OtpNumberField> fields = [];
    final text = notifier.otpController.text;
    final otpLength = text.length;
    for (int i = 0; i < 6; i++) {
      if (i < otpLength) {
        fields.add(OtpNumberField(text: text[i]));
      } else {
        fields.add(OtpNumberField(text: null));
      }
    }
    return fields;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        notifier.otpFocusNode.unfocus();
        Future.delayed(Duration(milliseconds: 500), () => notifier.otpFocusNode.requestFocus());
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _buildOtpFields(),
      ),
    );
  }
}
