import 'package:flutter/material.dart';
import 'package:following_practices/front/lib/theme/app_colors.dart';

/// Encabezado con gradiente para pantallas principales.
class AppPageHeader extends StatelessWidget {
  AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    Gradient? gradient,
  }) : gradient = gradient ?? AppColors.primaryGradient;

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// Barra de acciones del AppBar con iconos sobre fondo claro/gradiente.
class AppHeaderActions extends StatelessWidget {
  const AppHeaderActions({
    super.key,
    required this.actions,
    this.onLightBackground = false,
  });

  final List<Widget> actions;
  final bool onLightBackground;

  @override
  Widget build(BuildContext context) {
    final iconColor = onLightBackground ? AppColors.textPrimary : Colors.white;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: actions.map((action) {
        if (action is IconButton) {
          return IconButton(
            icon: action.icon,
            onPressed: action.onPressed,
            tooltip: action.tooltip,
            color: iconColor,
          );
        }
        return action;
      }).toList(),
    );
  }
}
