import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class PrimaryElevatedButton extends StatelessWidget {
  const PrimaryElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.image,
    this.width,
    this.dense = false,
    this.secondary = false,
    this.red = false,
    this.short = false,
    this.size,
  });

  final String text;
  final VoidCallback onPressed;
  final String? image;
  final double? width;
  final bool dense;
  final bool secondary;
  final bool red;
  final bool short;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final height = short ? 40.0 : 56.0;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: red
            ? kRedColor
            : secondary
                ? color.secondary
                : color.primary,
        minimumSize: size ?? (width != null
            ? Size(width!, height)
            : dense
                ? null
                : Size(double.infinity, height)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          image != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Image.asset(
                    image!,
                    width: 24,
                    height: 24,
                    color: secondary ? color.onSecondary : color.onPrimary,
                  ),
                )
              : const SizedBox(),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: secondary ? color.onSecondary : color.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
