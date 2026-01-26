import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class XTextFormFieldTheme {
  XTextFormFieldTheme._();

  // Light Theme For Input Field
  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: XColors.grey,
    suffixIconColor: XColors.success,
    hintStyle: const TextStyle(fontSize: 13, color: XColors.grey),
    labelStyle: const TextStyle(fontSize: 13, color: XColors.grey),
    floatingLabelStyle: const TextStyle(fontSize: 13, color: XColors.grey),
    errorStyle: const TextStyle(
      fontSize: 13,
      fontStyle: FontStyle.normal,
      color: XColors.warning,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: XColors.borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: XColors.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: XColors.borderColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: XColors.warning),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: XColors.warning),
    ),
  );

  // Dark Theme For Input Field
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: XColors.grey,
    suffixIconColor: XColors.success,
    hintStyle: const TextStyle(fontSize: 13, color: XColors.grey),
    labelStyle: const TextStyle(fontSize: 13, color: XColors.grey),
    floatingLabelStyle: const TextStyle(fontSize: 13, color: XColors.grey),
    errorStyle: const TextStyle(
      fontSize: 13,
      fontStyle: FontStyle.normal,
      color: XColors.warning,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: XColors.borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: XColors.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: XColors.borderColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: XColors.warning),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(width: 1, color: XColors.warning),
    ),
  );
}
