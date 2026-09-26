import 'package:flutter/material.dart';
import 'package:digital_shores/core/enums.dart';

// looks the user's role and gives back a colour for it.
// role can be null if it doesn't know it yet
Color getColorForRole(UserRole? role) {
  if (role == UserRole.user) {
    return Colors.blue;
  }

  if (role == UserRole.secretary) {
    return Colors.teal;
  }

  if (role == UserRole.admin) {
    return Colors.deepOrange;
  }

  if (role == UserRole.superAdmin) {
    return Colors.purple;
  }

  // If it doesn't know the role, just use blue
  return Colors.blue;
}

// This function takes the current theme and swaps out its main color
// (colorScheme.primary) for the color that matches the user's role.
// Any widget in the app that uses Theme.of(context).colorScheme.primary
// will then automatically show the new color.
ThemeData withRoleColor(BuildContext context, UserRole? role) {
  ThemeData currentTheme = Theme.of(context);
  Color roleColor = getColorForRole(role);

  return currentTheme.copyWith(
    colorScheme: currentTheme.colorScheme.copyWith(
      primary: roleColor,
      onPrimary: Colors.white,
    ),
  );
}
