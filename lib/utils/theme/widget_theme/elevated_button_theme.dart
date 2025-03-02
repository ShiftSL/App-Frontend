import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/* -- Light & Dark Elevated Button Themes -- */
class TElevatedButtonTheme {
  TElevatedButtonTheme._(); //To avoid creating instances

  /* -- Light Theme -- */
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
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
          color: ShiftslColors.textWhite,
          fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShiftslSizes.buttonRadius)),
    ),
  );
}
