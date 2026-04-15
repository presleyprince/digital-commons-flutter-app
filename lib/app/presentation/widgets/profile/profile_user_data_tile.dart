import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class ProfileUserDataTile extends StatelessWidget {
  const ProfileUserDataTile({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: kTitle7TextStyle.copyWith(color: color.primary),
        ),
        SizedBox(height: 8),
        Text(
          value ?? '-',
          style: kTitle7TextStyle,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
