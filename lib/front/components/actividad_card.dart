import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/actividad_list_item_dto.dart';
import 'package:following_practices/front/components/estado_badge.dart';

class ActividadCard extends StatelessWidget {
  const ActividadCard({
    super.key,
    required this.actividad,
    this.onTap,
  });

  final ActividadListItemDto actividad;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(actividad.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (actividad.estudianteNombre != null)
              Text(actividad.estudianteNombre!),
            Text('${actividad.fecha} · ${actividad.horasCumplidas} h'),
          ],
        ),
        trailing: EstadoBadge(estado: actividad.estado),
      ),
    );
  }
}
