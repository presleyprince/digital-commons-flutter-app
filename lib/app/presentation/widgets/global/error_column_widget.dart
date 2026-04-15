import 'package:digital_shores/app/presentation/widgets/global/primary_elevated_button.dart';
import 'package:flutter/material.dart';

class ErrorColumnWidget extends StatelessWidget {
  const ErrorColumnWidget({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          PrimaryElevatedButton(
            text: 'Coba lagi',
            onPressed: onPressed,
            dense: true,
          ),
        ],
      ),
    );
  }
}
