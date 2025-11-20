import 'package:flutter/material.dart';

class AppColors {
  // Temel Renkler
  static const Color creamBackground = Color(0xFFFFFBF5);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);

  // Mavi Tonları
  static const Color blueAccent = Color(0xFF3498DB);
  static const Color lightBlueLight = Color(0xFF5DADE2);
  static const Color gradientBlueStart = Color(0xFF2196F3);
  static const Color gradientBlueEnd = Color(0xFF1976D2);

  // Yeşil Tonları
  static const Color greenAccent = Color(0xFF27AE60);
  static const Color lightGreen = Color(0xFF52C77A);

  // Turuncu Tonları
  static const Color orangeAccent = Color(0xFFF39C12);
  static const Color lightOrange = Color(0xFFF5B041);

  // Kırmızı Tonları
  static const Color redAccent = Color(0xFFE74C3C);
  static const Color lightRed = Color(0xFFEC7063);

  // Gri Tonları
  static const Color lightGrey = Color(0xFFECF0F1);
  static const Color mediumGrey = Color(0xFFBDC3C7);
  static const Color darkGrey = Color(0xFF95A5A6);

  // Gradient Tanımlamaları
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientBlueStart, gradientBlueEnd],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen, greenAccent],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightOrange, orangeAccent],
  );

  // Gölge Renkleri
  static Color blueShadow = blueAccent.withOpacity(0.2);
  static Color greenShadow = greenAccent.withOpacity(0.2);
  static Color orangeShadow = orangeAccent.withOpacity(0.2);
  static Color redShadow = redAccent.withOpacity(0.2);
}

