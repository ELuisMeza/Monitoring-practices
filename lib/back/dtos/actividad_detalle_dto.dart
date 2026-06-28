import 'package:following_practices/back/dtos/observacion_dto.dart';

/// Detalle completo de una actividad con observaciones.
class ActividadDetalleDto {
  const ActividadDetalleDto({
    required this.id,
    required this.practicaId,
    required this.fecha,
    required this.descripcion,
    required this.horasCumplidas,
    this.evidenciaUrl,
    required this.estado,
    required this.observaciones,
    this.estudianteNombre,
  });

  final int id;

  final int practicaId;

  final String fecha;

  final String descripcion;

  final double horasCumplidas;

  final String? evidenciaUrl;

  final String estado;

  final List<ObservacionDto> observaciones;

  final String? estudianteNombre;
}