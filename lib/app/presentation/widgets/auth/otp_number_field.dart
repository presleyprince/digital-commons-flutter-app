import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class OtpNumberField extends StatelessWidget {
  const OtpNumberField({
    super.key,
    this.text,
  });

  final String? text;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      width: 45,
      decoration: BoxDecoration(
        color: text != null ? color.primary : color.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text ?? '',
          style: TextStyle(
            color: kWhiteColor,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
