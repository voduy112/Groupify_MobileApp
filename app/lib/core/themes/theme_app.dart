import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Dongle',
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Color(0xFFF6F7D3),
      appBarTheme: const AppBarTheme(
        titleTextStyle: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF305973),
        ),
        backgroundColor: Color(0xFFF6F7D3),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF305973),
        ),
        titleSmall: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontSize: 27),
        labelLarge: TextStyle(fontSize: 20),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
        height: 50,
        minWidth: 100,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          minimumSize: const Size(30, 30),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'Dongle',
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontSize: 18),
        bodyLarge: TextStyle(fontSize: 20),
        labelLarge: TextStyle(fontSize: 16),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
