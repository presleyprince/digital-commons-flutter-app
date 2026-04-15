import 'package:digital_shores/app/presentation/widgets/input/primary_text_field.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class TextInputColumn extends StatelessWidget {
  const TextInputColumn({
    super.key,
    required this.text,
    required this.controller,
    required this.formKey,
    required this.hintText,
    this.prefix,
    this.email = false,
    this.number = false,
    this.isPassword = false,
    this.isLastInput = false,
    this.onComplete,
    this.validator,
    this.validatorText = 'Form harus diisi',
    this.arterisk = false,
    this.autoFocus = false,
    this.titlePrimary = false,
    this.currency = false,
    // this.prefixText,
  });

  final String text;
  final TextEditingController controller;
  final String hintText;
  final GlobalKey<FormState> formKey;
  final Widget? prefix;
  final bool email;
  final bool number;
  final bool isPassword;
  final bool isLastInput;
  final void Function()? onComplete;
  final bool Function(String value)? validator;
  final String validatorText;
  final bool arterisk;
  final bool autoFocus;
  final bool titlePrimary;
  final bool currency;
  // final String? prefixText;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                text,
                style: kTitle6TextStyle.copyWith(
                  color: titlePrimary ? color.primary : null,
                ),
              ),
              if (arterisk)
                Text(
                  '*',
                  style: kTitle6TextStyle.copyWith(
                    color: kRedColor,
                  ),
                ),
            ],
          ),
          PrimaryTextField(
            controller: controller,
            hintText: hintText,
            formKey: formKey,
            prefix: prefix,
            email: email,
            number: number,
            isPassword: isPassword,
            isLastInput: isLastInput,
            onComplete: onComplete,
            validator: validator,
            validatorText: validatorText,
            autoFocus: autoFocus,
            currency: currency,
            // prefixText: prefixText,
          ),
        ],
      ),
    );
  }
}
