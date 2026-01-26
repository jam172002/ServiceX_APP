import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class XCheckboxTheme {
  XCheckboxTheme._();

  // Light Theme For CheckBox
  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith(
      (states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            } else {
              return Colors.black;
            }
          }
          as WidgetPropertyResolver<Color?>,
    ),
    fillColor: WidgetStateProperty.resolveWith(
      (states) {
            if (states.contains(WidgetState.selected)) {
              return XColors.primary;
            } else {
              return Colors.transparent;
            }
          }
          as WidgetPropertyResolver<Color?>,
    ),
  );

  //Dark Theme For CheckBox
  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith(
      (states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            } else {
              return Colors.black;
            }
          }
          as WidgetPropertyResolver<Color?>,
    ),
    fillColor: WidgetStateProperty.resolveWith(
      (states) {
            if (states.contains(WidgetState.selected)) {
              return XColors.primary;
            } else {
              return Colors.transparent;
            }
          }
          as WidgetPropertyResolver<Color?>,
    ),
  );
}
