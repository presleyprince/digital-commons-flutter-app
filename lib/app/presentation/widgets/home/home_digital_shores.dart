import 'package:digital_shores/app/presentation/widgets/home/home_menu_tile.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:digital_shores/app/domain/entities/home_menu.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/const/resource.dart';
import 'package:provider/provider.dart';

class HomeDigitalShoresMenu extends StatelessWidget {
  const HomeDigitalShoresMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier =
    Provider.of<AuthNotifier>(context, listen: false);

    final isSuperAdmin = authNotifier.isSuperAdmin();

    final List<HomeMenu> menuItems = List.from(kHomeMenu);

    if (isSuperAdmin) {
      menuItems.add(
        HomeMenu(
          image: R.ASSETS_ICONS_MY_DOCUMENT_PNG,
          title: 'Kelola Pengguna',
          route: 'manage-users',
        ),
      );
    }   
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Jelajahi $kAppName', style: kTitle5TextStyle),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: menuItems // kHomeMenu   
              .take(3) // changed to 3 due to new button
              .map((menu) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: HomeMenuTile(menu: menu),
                  ),
              ),
              )
              .toList(),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: menuItems //kHomeMenu
              .skip(3)  //.sublist(3) // changed to 3, after merge and 4 features display
              .map((menu) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: HomeMenuTile(menu: menu),
                  ),
              ),
              )
              .toList(),
        ),
      ],
    );
  }
}
