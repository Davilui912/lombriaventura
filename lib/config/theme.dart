import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Paleta de colores vibrante para niños
  static const Color verde = Color(0xFF4CAF50);
  static const Color verdeClaro = Color(0xFF81C784);
  static const Color cafe = Color(0xFF795548);
  static const Color cafeClaro = Color(0xFFA1887F);
  static const Color amarillo = Color(0xFFFFC107);
  static const Color amarilloClaro = Color(0xFFFFD54F);
  static const Color azulCielo = Color(0xFF42A5F5);
  static const Color azulClaro = Color(0xFF90CAF9);
  static const Color rosa = Color(0xFFEC407A);
  static const Color naranja = Color(0xFFFF7043);
  static const Color fondo = Color(0xFFF5F5F5);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color negro = Color(0xFF263238);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Fredoka',
      brightness: Brightness.light,
      
      // 🎨 Esquema de colores
      colorScheme: ColorScheme.fromSeed(
        seedColor: verde,
        primary: verde,
        secondary: amarillo,
        tertiary: azulCielo,
        error: Colors.red,
        surface: blanco,
        onPrimary: blanco,
        onSecondary: negro,
        onSurface: negro,
      ),
      
      // 🖼️ Fondo general
      scaffoldBackgroundColor: fondo,
      
      // 📝 Tipografía
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: negro),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: negro),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: negro),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: negro),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: negro),
        bodyLarge: TextStyle(fontSize: 16, color: negro),
        bodyMedium: TextStyle(fontSize: 14, color: negro),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      
      // 🔘 Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: verde,
          foregroundColor: blanco,
          minimumSize: const Size(double.infinity, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          elevation: 4,
          shadowColor: verde.withValues(alpha: 0.3),
        ),
      ),
      
      // 🔘 Botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: verde,
          textStyle: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // 🔘 Botones de ícono
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: verde,
        ),
      ),
      
      // 🏷️ AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: verde,
        foregroundColor: blanco,
        centerTitle: false,
        elevation: 4,
        shadowColor: verde.withValues(alpha: 0.3),
        titleTextStyle: const TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: blanco,
        ),
        iconTheme: const IconThemeData(color: blanco),
      ),
      
      // 📋 Tarjetas (CORREGIDO: CardThemeData)
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: blanco,
        margin: const EdgeInsets.only(bottom: 12),
      ),
      
      // 📝 Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: blanco,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: verde, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIconColor: verde,
        suffixIconColor: verde,
      ),
      
      // 📋 Listas
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // 📊 Progreso
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: verde,
        circularTrackColor: Colors.grey.shade200,
      ),
      
      // 🎯 Chips
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: verde,
        labelStyle: const TextStyle(fontFamily: 'Fredoka'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // 📦 Diálogos (CORREGIDO: DialogThemeData)
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
      ),
      
      // 📦 SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: negro,
        contentTextStyle: const TextStyle(color: blanco, fontSize: 14),
      ),
    );
  }
}