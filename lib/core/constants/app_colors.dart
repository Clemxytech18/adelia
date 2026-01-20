import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors extracted from designs
  static const Color primary = Color(0xFF72AE8C); // Muted Green
  static const Color secondary = Color(0xFFF5CC5C); // Mustard Yellow
  static const Color tertiary = Color(0xFFA0C9F4); // Light Blue

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);

  static const Color text = Color(0xFF333333);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFE57373);

  // Gradients
  static const LinearGradient homeGradient = LinearGradient(
    colors: [primary, Color(0xFF83B89A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
