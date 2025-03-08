import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/* -- Light & Dark Elevated Button Themes -- */
class ShiftslElevatedButtonTheme {
  ShiftslElevatedButtonTheme._(); //To avoid creating instances

  /* -- Light Theme -- */
  static final elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: ShiftslColors.primaryColor,
      backgroundColor: ShiftslColors.primaryColor,
      disabledForegroundColor: ShiftslColors.darkGrey,
      disabledBackgroundColor: ShiftslColors.buttonDisabled,
      side: const BorderSide(color: ShiftslColors.primaryColor),
      padding: const EdgeInsets.symmetric(vertical: ShiftslSizes.buttonHeight),
      textStyle: const TextStyle(
          fontSize: 16,
          color: Color.fromARGB(255, 255, 255, 255),
          fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShiftslSizes.buttonRadius)),
    ),
  );
}
