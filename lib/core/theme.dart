import 'package:digital_shores/core/constants.dart';
import 'package:flutter/material.dart';

const _white = Color(0xffFFFFFF);
const _black = Color(0xff1E1E1E);
const _grey = Color(0xffA8A8A8);
const _backgroundWhite = Color(0xffFFFFFF);

const _primary = Color(0xff46BCE8);
const _secondary = Color(0xffDAF5FF);
// const _secondary = Color(0xff7EEDA0);

class AppTheme {
  ThemeData theme = ThemeData(
    fontFamily: "SegoeUI",
    colorScheme: const ColorScheme.light(
      primary: _primary,
      secondary: _secondary,
      onPrimary: _backgroundWhite,
      onSecondary: _black,
      // onTertiary: _white,
      surface: _backgroundWhite,
      onSurface: _black,
      onSurfaceVariant: _grey,
      shadow: _grey,
    ),
    appBarTheme: const AppBarTheme(
      scrolledUnderElevation: 0.0,
      surfaceTintColor: _white,
      elevation: 0,
      shadowColor: Colors.black,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: _black,
        fontWeight: kFontweightBold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(_primary),
        foregroundColor: WidgetStateProperty.all<Color>(_backgroundWhite),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontSize: 18,
            fontWeight: kFontweightSemiBold,
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return _backgroundWhite.withValues(alpha: 0.2);
            }
            return _primary;
          },
        ),
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side: WidgetStateProperty.all<BorderSide>(
          const BorderSide(
            color: _primary,
            width: 2.0,
          ),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(_white),
        foregroundColor: WidgetStateProperty.all<Color>(_primary),
        textStyle: WidgetStateProperty.all<TextStyle>(
          const TextStyle(
            fontSize: 16,
            fontWeight: kFontweightSemiBold,
          ),
        ),
        overlayColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return _backgroundWhite.withValues(alpha: 0.2);
            }
            return _primary;
          },
        ),
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
    checkboxTheme: const CheckboxThemeData(
      side: BorderSide(
        color: kGreyColor,
        width: 2.0,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _primary,
    ),
    datePickerTheme: DatePickerThemeData(
      cancelButtonStyle: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(_primary),
      ),
      confirmButtonStyle: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(_primary),
      ),
    ),
  );
}
