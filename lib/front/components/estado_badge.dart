import 'package:flutter/material.dart';
import 'package:following_practices/front/lib/theme/app_colors.dart';

class EstadoBadge extends StatelessWidget {
  const EstadoBadge({super.key, required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final (color, label) = _estilo(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  (Color, String) _estilo(String estado) {
    switch (estado) {
      case 'aprobado':
        return (AppColors.success, 'Aprobado');
      case 'rechazado':
        return (AppColors.error, 'Rechazado');
      case 'observado':
        return (AppColors.warning, 'Observado');
      default:
        return (AppColors.info, 'Registrado');
    }
  }
}
