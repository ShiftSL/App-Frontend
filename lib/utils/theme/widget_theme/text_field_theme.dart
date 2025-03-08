import 'package:flutter/material.dart';
import 'package:shift_sl/utils/constants/colors.dart';

class ShiftslTextFieldTheme {
  ShiftslTextFieldTheme._();

  static InputDecorationTheme lnputDecorationTheme = InputDecorationTheme(
      border: OutlineInputBorder(),
      prefixIconColor: ShiftslColors.primaryColor,
      floatingLabelStyle: TextStyle(color: ShiftslColors.primaryColor),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 2, color: ShiftslColors.primaryColor),
      )); // OutlineInputBorder, InputDecorationTheme
}
