import 'package:flutter/material.dart';

class EstadoBadge extends StatelessWidget {
  const EstadoBadge({super.key, required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final (color, label) = _estilo(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  (Color, String) _estilo(String estado) {
    switch (estado) {
      case 'aprobado':
        return (Colors.green, 'Aprobado');
      case 'rechazado':
        return (Colors.red, 'Rechazado');
      case 'observado':
        return (Colors.orange, 'Observado');
      default:
        return (Colors.blueGrey, 'Registrado');
    }
  }
}
