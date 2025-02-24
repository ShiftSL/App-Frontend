import 'package:flutter/material.dart';

class ShiftSlLogo extends StatelessWidget {
  final double width;
  final double height;

  const ShiftSlLogo({
    Key? key,
    this.width = 250,
    this.height = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure shift_sl_logo.png is in assets/images/shift_sl_logo.png
    return Image.asset(
      'assets/images/shift_sl_logo.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
