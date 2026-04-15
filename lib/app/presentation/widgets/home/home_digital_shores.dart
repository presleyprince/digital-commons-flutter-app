import 'package:digital_shores/app/presentation/widgets/home/home_menu_tile.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

class HomeDigitalShoresMenu extends StatelessWidget {
  const HomeDigitalShoresMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jelajahi $kAppName', style: kTitle5TextStyle),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: kHomeMenu
              .take(3)
              .map(
                (menu) => HomeMenuTile(menu: menu),
              )
              .toList(),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: kHomeMenu
              .sublist(3)
              .map(
                (menu) => HomeMenuTile(menu: menu),
              )
              .toList(),
        ),
      ],
    );
  }
}
