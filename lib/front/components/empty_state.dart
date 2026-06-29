import 'package:flutter/material.dart';
import 'package:following_practices/front/components/animated_fade_slide.dart';
import 'package:following_practices/front/lib/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.mensaje,
    this.accion,
  });

  final IconData icon;
  final String mensaje;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return AnimatedFadeSlide(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 56,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              if (accion != null) ...[
                const SizedBox(height: 20),
                accion!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
