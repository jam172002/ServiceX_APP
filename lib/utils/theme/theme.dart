import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';
import 'package:servicex_client_app/utils/theme/custom/appbar_theme.dart';
import 'package:servicex_client_app/utils/theme/custom/bottom_sheet_theme.dart';
import 'package:servicex_client_app/utils/theme/custom/checkbox_theme.dart';
import 'package:servicex_client_app/utils/theme/custom/chip_theme.dart';
import 'package:servicex_client_app/utils/theme/custom/elevated_button_theme.dart';
import 'package:servicex_client_app/utils/theme/custom/outlined_button_theme.dart';
import 'package:servicex_client_app/utils/theme/custom/text_button_theme.dart';
import 'package:servicex_client_app/utils/theme/custom/text_field_theme.dart';
import 'package:servicex_client_app/utils/theme/custom/text_theme.dart';

class XAppTheme {
  XAppTheme._();

  //Light Theme of APP
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    primaryColor: XColors.primary,
    scaffoldBackgroundColor: XColors.primaryBG,
    textTheme: XTextTheme.lightTextTheme,
    elevatedButtonTheme: XElevatedButtonTheme.lightElevatedButtonTheme,
    appBarTheme: XAppbarTheme.lightAppbarTheme,
    bottomSheetTheme: XBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: XCheckboxTheme.lightCheckboxTheme,
    chipTheme: XChipTheme.lightChipTheme,
    outlinedButtonTheme: XOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: XTextFormFieldTheme.lightInputDecorationTheme,
    textButtonTheme: XTextButtonTheme.lightTextButtonTheme,
  );

  //Dark Theme Of APP
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.dark,
    primaryColor: XColors.primary,
    scaffoldBackgroundColor: XColors.primaryBG,
    textTheme: XTextTheme.darkTextTheme,
    elevatedButtonTheme: XElevatedButtonTheme.darkElevatedButtonTheme,
    appBarTheme: XAppbarTheme.darkAppbarTheme,
    bottomSheetTheme: XBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme: XCheckboxTheme.darkCheckboxTheme,
    chipTheme: XChipTheme.darkChipTheme,
    outlinedButtonTheme: XOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: XTextFormFieldTheme.darkInputDecorationTheme,
    textButtonTheme: XTextButtonTheme.darkTextButtonTheme,
  );
}
