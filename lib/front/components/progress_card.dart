import 'package:flutter/material.dart';

class ProgressCard extends StatelessWidget {
  const ProgressCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.maximo,
    this.subtitulo,
  });

  final String titulo;
  final double valor;
  final double maximo;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    final porcentaje = maximo > 0 ? (valor / maximo).clamp(0.0, 1.0) : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            if (subtitulo != null) ...[
              const SizedBox(height: 4),
              Text(subtitulo!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            LinearProgressIndicator(value: porcentaje),
            const SizedBox(height: 8),
            Text(
              '${valor.toStringAsFixed(1)} / ${maximo.toStringAsFixed(0)} h '
              '(${(porcentaje * 100).toStringAsFixed(0)}%)',
            ),
          ],
        ),
      ),
    );
  }
}
