import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class XTextButtonTheme {
  static final lightTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: XColors.black,
    ),
  );

  static final darkTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: XColors.black,
    ),
  );
}
