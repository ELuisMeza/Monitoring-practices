import 'package:flutter/material.dart';

/// Tema visual compartido de la aplicación.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    );
  }
}
