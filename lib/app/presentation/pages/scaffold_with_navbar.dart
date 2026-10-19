import 'package:digital_shores/const/resource.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _NavTab {
  const _NavTab({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final String icon;
}

const List<_NavTab> _tabs = [
  _NavTab(path: '/home', label: 'Beranda', icon: R.ASSETS_ICONS_HOME_PNG),
  _NavTab(path: '/seaweed-home', label: 'LahanKu', icon: R.ASSETS_ICONS_MY_PLOT_PNG),
  _NavTab(path: '/my-finance', label: 'KeuanganKu', icon: R.ASSETS_ICONS_MY_FINANCIAL_PNG),
  _NavTab(path: '/information', label: 'Informasi', icon: R.ASSETS_ICONS_INFORMATION_PNG),
  _NavTab(path: '/profile', label: 'Profil', icon: R.ASSETS_ICONS_PROFILE_PNG),
];

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final bigScreen = MediaQuery.of(context).size.width > 480;
    final activeColor = color.onPrimary;
    final inActiveColor = color.primary;
    final labelStyle = DefaultTextStyle.of(context).style.merge(
          TextStyle(fontSize: 16, fontWeight: kFontweightSemiBold),
        );
    double labelWidth = 0;
    for (final tab in _tabs) {
      final painter = TextPainter(
        text: TextSpan(text: tab.label, style: labelStyle),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      if (painter.width > labelWidth) labelWidth = painter.width;
    }
    labelWidth = labelWidth.ceilToDouble() + 1;

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
                border: Border(
                  top: BorderSide(
                    color: color.primary,
                    width: 2,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                showUnselectedLabels: false,
                showSelectedLabels: false,
                type: BottomNavigationBarType.fixed,
                unselectedItemColor: inActiveColor,
                selectedItemColor: activeColor,
                items: [
                  for (var i = 0; i < _tabs.length; i++)
                    _buildItem(
                      tab: _tabs[i],
                      selected: i == navigationShell.currentIndex,
                      color: color,
                      activeColor: activeColor,
                      inActiveColor: inActiveColor,
                      labelWidth: labelWidth,
                    ),
                ],
                currentIndex: navigationShell.currentIndex,
                onTap: (int idx) => context.go(_tabs[idx].path),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildItem({
    required _NavTab tab,
    required bool selected,
    required ColorScheme color,
    required Color activeColor,
    required Color inActiveColor,
    required double labelWidth,
  }) {
    final fg = selected ? activeColor : inActiveColor;
    final bg = selected ? inActiveColor : activeColor;
    
    return BottomNavigationBarItem(
      backgroundColor: color.primary,
      label: tab.label,
      icon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(kDefaultRadius),
          ),
          width: double.infinity,
          // space between the edge of blue box and the icon and label
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
          child: Column(
            children: [
              Image(
                image: AssetImage(tab.icon),
                color: fg,
                width: 32,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: labelWidth,
                  child: Text(
                    tab.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: kFontweightSemiBold,
                      color: fg,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}