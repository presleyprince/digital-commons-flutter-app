import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  void _onItemTapped(int index, BuildContext context) {
    navigationShell.goBranch(
      index,
      initialLocation: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final bigScreen = MediaQuery.of(context).size.width > 480;
    final activeColor = color.onPrimary;
    final inActiveColor = color.primary;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 480,
          ),
          child: navigationShell,
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: bigScreen ? 0 : 1,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              decoration: BoxDecoration(
                // boxShadow: [
                //   BoxShadow(
                //     color: color.shadow.withValues(alpha: 0.15),
                //     spreadRadius: 0,
                //     blurRadius: 14.0,
                //     offset: const Offset(0, -4),
                //   ),
                // ],
                border: Border(
                  top: BorderSide(
                    color: color.primary,
                    width: 2,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                // backgroundColor: color.surface,
                showUnselectedLabels: false,
                showSelectedLabels: false,
                type: BottomNavigationBarType.fixed,
                unselectedItemColor: inActiveColor,
                selectedItemColor: activeColor,
                items: [
                  BottomNavigationBarItem(
                    backgroundColor: color.primary,
                    icon: Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: navigationShell.currentIndex == 0 ? inActiveColor : activeColor,
                          borderRadius: BorderRadius.circular(kDefaultRadius),
                        ),
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          children: [
                            Image(
                              image: const AssetImage(R.ASSETS_ICONS_HOME_PNG),
                              color:
                                  navigationShell.currentIndex == 0 ? activeColor : inActiveColor,
                              width: 32,
                            ),
                            Text(
                              'Beranda',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: kFontweightSemiBold,
                                color:
                                    navigationShell.currentIndex == 0 ? activeColor : inActiveColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    backgroundColor: color.primary,
                    icon: Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: navigationShell.currentIndex == 1 ? inActiveColor : activeColor,
                          borderRadius: BorderRadius.circular(kDefaultRadius),
                        ),
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          children: [
                            Image(
                              image: const AssetImage(R.ASSETS_ICONS_PROFILE_PNG),
                              color:
                                  navigationShell.currentIndex == 1 ? activeColor : inActiveColor,
                              width: 32,
                            ),
                            Text(
                              'Profil',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: kFontweightSemiBold,
                                color:
                                    navigationShell.currentIndex == 1 ? activeColor : inActiveColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    label: 'Profil',
                  ),
                ],
                currentIndex: navigationShell.currentIndex,
                onTap: (int idx) => _onItemTapped(idx, context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
