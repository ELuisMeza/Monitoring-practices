/// Observación de revisión sobre una actividad.
class ObservacionDto {
  const ObservacionDto({
    required this.id,
    required this.actividadId,
    required this.usuarioId,
    required this.autorNombre,
    required this.texto,
    required this.createdAt,
  });

  final int id;
  final int actividadId;
  final int usuarioId;
  final String autorNombre;
  final String texto;
  final String createdAt;
}
