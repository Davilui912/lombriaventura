import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores oficial
  static const Color verde = Color(0xFF7AC943);
  static const Color cafe = Color(0xFF8B5E3C);
  static const Color amarillo = Color(0xFFFFD93D);
  static const Color azulCielo = Color(0xFF6EC6FF);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color fondo = Color(0xFFF5F9EE);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: verde,
        primary: verde,
        secondary: amarillo,
        tertiary: azulCielo,
        surface: blanco,
      ),
      scaffoldBackgroundColor: fondo,
      
      // Botones grandes y redondeados (para niños)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: verde,
          foregroundColor: blanco,
          minimumSize: const Size(200, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: verde,
        foregroundColor: blanco,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: blanco,
        ),
      ),
    );
  }
}