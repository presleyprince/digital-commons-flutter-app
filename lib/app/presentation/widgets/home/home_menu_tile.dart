import 'package:digital_shores/app/domain/entities/home_menu.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/router.dart';
import 'package:flutter/material.dart';

class HomeMenuTile extends StatelessWidget {
  const HomeMenuTile({
    super.key,
    required this.menu,
  });

  final HomeMenu menu;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => router.go('/home/${menu.route}'),
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.grey.withValues(alpha: 0.3),
      highlightColor: Colors.grey.withValues(alpha: 0.1),
      child: Container(
        width: 110,
        color: Colors.transparent,
        child: Column(
          children: [
            Image.asset(
              menu.image,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
            Container(
              decoration: BoxDecoration(
                color: color.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                menu.title,
                style: kTitle7TextStyle.copyWith(color: color.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
