import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class DigitalShoresIntroductionColumn extends StatelessWidget {
  const DigitalShoresIntroductionColumn({
    super.key,
    this.titleBlue = true,
  });

  final bool titleBlue;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Column(
      children: [
        !titleBlue
            ? Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Image.asset(
                      R.ASSETS_IMAGES_APP_LOGO_PNG,
                      height: 64,
                    ),
                    const SizedBox(width: 10),
                    Text('Hai Sobat Laut!', style: kTitle5TextStyle),
                  ],
                ),
              )
            : SizedBox(),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kDefaultRadius),
            image: DecorationImage(
              image: AssetImage(
                R.ASSETS_IMAGES_BEACH_PNG,
              ),
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          kAppName,
          textAlign: TextAlign.center,
          style: kTitle5TextStyle.copyWith(
            color: titleBlue ? color.primary : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Terhubung dengan dunia, berlabuh di $kAppName.',
          style: kSubtitle5TextStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
