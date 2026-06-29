import 'package:flutter/material.dart';
import 'package:following_practices/front/lib/router.dart';
import 'package:following_practices/front/lib/theme/app_theme.dart';

/// Raíz de la aplicación móvil (configuración global del front).
class FollowingPracticesApp extends StatelessWidget {
  const FollowingPracticesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Seguimiento de Prácticas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
