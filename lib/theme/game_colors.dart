import 'package:flutter/material.dart';

class GameColors {
  // Backgrounds
  static const Color bgTop = Color(0xFF6B7BFF); // Soft blue-purple
  static const Color bgBottom = Color(0xFF28B5F5); // Bright cyan
  
  static const LinearGradient mainBackground = LinearGradient(
    colors: [bgTop, bgBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.3, 1.0],
  );

  // Containers
  static const Color darkBluePanel = Color(0xFF144D94); // Dark blue for stats panels
  static const Color cyanPanel = Color(0xFF33C0FF); // Light cyan for inner panels
  static const Color panelBorder = Color(0xFF0F3A70);

  // Buttons
  static const Color btnYellowTop = Color(0xFFFFD633);
  static const Color btnYellowBottom = Color(0xFFD69400);
  
  static const Color btnGreenTop = Color(0xFF5CE62E);
  static const Color btnGreenBottom = Color(0xFF389914);

  static const Color btnRedTop = Color(0xFFFF4D4D);
  static const Color btnRedBottom = Color(0xFFB32424);

  static const Color btnBlueTop = Color(0xFF33A3FF);
  static const Color btnBlueBottom = Color(0xFF1A66B3);

  // Borders & Text
  static const Color outlineDark = Color(0xFF1A2138); // Very dark blue/black for borders
  static const Color textWhite = Colors.white;
  static const Color textBlack = Color(0xFF1A2138);
  static const Color textGreenAccent = Color(0xFF5CE62E); // For +values

  // Pills (Coins, Gems)
  static const Color pillBackground = Color(0xFF162032);
}
