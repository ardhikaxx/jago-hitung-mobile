import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_colors.dart';

class GameTextStyles {
  static TextStyle get titleLarge => GoogleFonts.baloo2(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: GameColors.textWhite,
  );
  
  static TextStyle get titleMedium => GoogleFonts.baloo2(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: GameColors.textWhite,
  );
  
  static TextStyle get buttonTextBlack => GoogleFonts.baloo2(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: GameColors.textBlack,
  );

  static TextStyle get buttonTextWhite => GoogleFonts.baloo2(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: GameColors.textWhite,
  );
  
  static TextStyle get statValue => GoogleFonts.baloo2(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: GameColors.textWhite,
  );

  static TextStyle get statBonus => GoogleFonts.baloo2(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: GameColors.textGreenAccent,
  );

  static TextStyle get labelSmall => GoogleFonts.fredoka(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white70,
  );
}
