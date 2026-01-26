import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class XOutlinedButtonTheme {
  XOutlinedButtonTheme._();

  // Common button shape and padding
  static final _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );
  static final _buttonPadding = const EdgeInsets.symmetric(
    vertical: 16,
    horizontal: 20,
  );

  // Light Theme
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStateProperty.all(0),
      padding: WidgetStateProperty.all(_buttonPadding),
      shape: WidgetStateProperty.all(_buttonShape),

      // Border color
      side: WidgetStateProperty.resolveWith<BorderSide>((states) {
        if (states.contains(WidgetState.pressed)) {
          return BorderSide.none; // No border on press
        }
        return const BorderSide(color: XColors.black); // Default border
      }),

      // Background color
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.pressed)) {
          return XColors.primary; // BG on press
        }
        return Colors.transparent; // Normal BG
      }),

      // Text & icon color
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.white; // Label/Icon on press
        }
        return XColors.primary; // Normal label color
      }),

      textStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );

  // Dark Theme
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStateProperty.all(0),
      padding: WidgetStateProperty.all(_buttonPadding),
      shape: WidgetStateProperty.all(_buttonShape),

      // Border color
      side: WidgetStateProperty.resolveWith<BorderSide>((states) {
        if (states.contains(WidgetState.pressed)) {
          return BorderSide.none;
        }
        return const BorderSide(color: XColors.black);
      }),

      // Background color
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.pressed)) {
          return XColors.primary;
        }
        return Colors.transparent;
      }),

      // Text & icon color
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.white;
        }
        return XColors.primary;
      }),

      textStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
