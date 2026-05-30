import 'package:flutter/material.dart';
import 'package:following_practices/front/lib/theme/app_theme.dart';
import 'package:following_practices/front/pages/home_page.dart';

/// Raíz de la aplicación móvil (configuración global del front).
class FollowingPracticesApp extends StatelessWidget {
  const FollowingPracticesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seguimiento de Prácticas',
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}
