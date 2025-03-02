import 'package:flutter/material.dart';

/// SHIFT SL brand colors
const Color kPrimaryColor = Color(0xFF131313); // #2B3C56
const Color kSecondaryColor = Color(0xFF2AED8D); // #2AED8D
const Color kDarkColor = Color(0xFF242424); // #242424
const Color kLightColor = Color(0xFFF7F7F7); // #F7F7F7

final ThemeData shiftSlTheme = ThemeData(
  primaryColor: kPrimaryColor,

  scaffoldBackgroundColor: kLightColor,

  fontFamily: 'Inter',

  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: kPrimaryColor,
    onPrimary: Colors.white,
    secondary: kSecondaryColor,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: kLightColor,
    onBackground: kDarkColor,
    surface: Colors.white,
    onSurface: kDarkColor,
  ),

  // Style for ElevatedButtons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kSecondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  // Define text styles. Adjust sizes and weights as needed.
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      color: kPrimaryColor,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      color: kPrimaryColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    bodyLarge: TextStyle(
      color: kDarkColor,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      color: kDarkColor,
      fontSize: 14,
    ),
  ),
);
