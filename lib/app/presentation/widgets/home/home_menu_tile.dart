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
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              menu.image,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(
                minWidth: 95,
                minHeight: 42,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4,),
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: menu.title.split(' ').map((word) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        word,
                        style: kTitle7TextStyle.copyWith(color: color.onPrimary),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            //Container(
              //decoration: BoxDecoration(
                //color: color.primary,
                //borderRadius: BorderRadius.circular(8),
              //),
              //padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //child: Text(
                //menu.title,
                //style: kTitle7TextStyle.copyWith(color: color.onPrimary),
              //),
            //),
          ],
        ),
      ),
    );
  }
}
