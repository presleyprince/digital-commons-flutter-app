import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class PrimaryOutlinedButton extends StatelessWidget {
  const PrimaryOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.dense = false,
    this.secondary = false,
    this.red = false,
  });

  final String text;
  final VoidCallback onPressed;
  final double? width;
  final bool dense;
  final bool secondary;
  final bool red;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: red
            ? kRedColor
            : secondary
                ? color.primary
                : color.surface,
        minimumSize: width != null
            ? Size(width!, 56.0)
            : dense
                ? null
                : const Size(double.infinity, 56.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: secondary ? color.onPrimary : color.primary,
        ),
      ),
    );
  }
}
