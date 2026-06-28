/// Item de actividad para listados.
class ActividadListItemDto {
  const ActividadListItemDto({
    required this.id,
    required this.fecha,
    required this.descripcion,
    required this.horasCumplidas,
    required this.estado,
    this.estudianteNombre,
  });

  final int id;

  final String fecha;

  final String descripcion;

  final double horasCumplidas;

  final String estado;

  final String? estudianteNombre;
}