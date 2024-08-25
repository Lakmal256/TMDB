import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _tintedForegroundColorLight = Color(0xFF000000);
  static const _tintedForegroundColorDark = Color(0xFFFFFFFF);
  static const _inputTextFieldColorForDark = Color(0xFF616161);
  static const _drawerTextColorForDark = Color(0xFFBDBDBD);

  static final light = ThemeData(
    useMaterial3: false,
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.light,
      primarySwatch: Colors.deepPurple,
      backgroundColor: Colors.grey[300],
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.grey[400]),
    textTheme: TextTheme(
      displaySmall: GoogleFonts.bebasNeue(
          fontSize: 52, fontWeight: FontWeight.normal, color: _tintedForegroundColorLight, letterSpacing: 1),
      headlineMedium: GoogleFonts.bebasNeue(
          fontSize: 34, fontWeight: FontWeight.normal, color: _tintedForegroundColorLight, letterSpacing: 1),
      headlineSmall: GoogleFonts.bebasNeue(
          fontSize: 24, fontWeight: FontWeight.normal, color: _tintedForegroundColorLight, letterSpacing: 1),
      titleLarge: GoogleFonts.bebasNeue(
          fontSize: 24, fontWeight: FontWeight.normal, color: _tintedForegroundColorLight, letterSpacing: 1),
      titleMedium: GoogleFonts.bebasNeue(
          fontSize: 20, fontWeight: FontWeight.normal, color: _tintedForegroundColorLight, letterSpacing: 1),
      titleSmall: GoogleFonts.bebasNeue(
          fontSize: 16, fontWeight: FontWeight.normal, color: _tintedForegroundColorLight, letterSpacing: 1),
      bodySmall: GoogleFonts.bebasNeue(
          fontSize: 12, fontWeight: FontWeight.normal, color: _tintedForegroundColorLight, letterSpacing: 1),
      labelLarge: GoogleFonts.lato(
          fontSize: 14, fontWeight: FontWeight.normal, color: _tintedForegroundColorLight, letterSpacing: 0.5),
      labelMedium: GoogleFonts.lato(
          fontSize: 22, fontWeight: FontWeight.bold, color: _tintedForegroundColorLight, letterSpacing: 1),
      labelSmall: GoogleFonts.bebasNeue(
          fontSize: 16, fontWeight: FontWeight.normal, color: _tintedForegroundColorLight, letterSpacing: 1),
    ),
    inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: _inputTextFieldColorForDark),
        prefixIconColor: _inputTextFieldColorForDark,
        suffixIconColor: _inputTextFieldColorForDark),
    tabBarTheme: const TabBarTheme(indicatorColor: Colors.deepPurple),
  );

  static final dark = ThemeData(
    useMaterial3: false,
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      backgroundColor: Colors.grey[850],
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.grey[800]),
    textTheme: TextTheme(
      displaySmall: GoogleFonts.bebasNeue(
          fontSize: 52, fontWeight: FontWeight.normal, color: _tintedForegroundColorDark, letterSpacing: 1),
      headlineMedium: GoogleFonts.bebasNeue(
          fontSize: 34, fontWeight: FontWeight.normal, color: _tintedForegroundColorDark, letterSpacing: 1),
      headlineSmall: GoogleFonts.bebasNeue(
          fontSize: 24, fontWeight: FontWeight.normal, color: _tintedForegroundColorDark, letterSpacing: 1),
      titleLarge: GoogleFonts.bebasNeue(
          fontSize: 24, fontWeight: FontWeight.normal, color: _tintedForegroundColorDark, letterSpacing: 1),
      titleMedium: GoogleFonts.bebasNeue(
          fontSize: 20, fontWeight: FontWeight.normal, color: _tintedForegroundColorDark, letterSpacing: 1),
      titleSmall: GoogleFonts.bebasNeue(
          fontSize: 16, fontWeight: FontWeight.normal, color: _tintedForegroundColorDark, letterSpacing: 1),
      bodySmall: GoogleFonts.bebasNeue(
          fontSize: 12, fontWeight: FontWeight.normal, color: _tintedForegroundColorDark, letterSpacing: 1),
      labelLarge: GoogleFonts.lato(
          fontSize: 14, fontWeight: FontWeight.normal, color: _tintedForegroundColorDark, letterSpacing: 0.5),
      labelMedium:
          GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold, color: _drawerTextColorForDark, letterSpacing: 1),
      labelSmall: GoogleFonts.bebasNeue(
          fontSize: 16, fontWeight: FontWeight.normal, color: _drawerTextColorForDark, letterSpacing: 1),
      bodyMedium: GoogleFonts.lato(
          fontSize: 14, fontWeight: FontWeight.normal, color: _tintedForegroundColorLight, letterSpacing: 1),
    ),
    inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: _inputTextFieldColorForDark),
        prefixIconColor: _inputTextFieldColorForDark,
        suffixIconColor: _inputTextFieldColorForDark),
    cardColor: Colors.grey[700],
    tabBarTheme: const TabBarTheme(indicatorColor: Colors.deepPurple),
  );
}
