/// Registro de asistencia (entrada/salida).
class AsistenciaDto {
  const AsistenciaDto({
    required this.id,
    required this.practicaId,
    required this.empresaId,
    required this.fecha,
    required this.hora,
    required this.tipo,
    this.estudianteNombre,
  });

  final int id;
  final int practicaId;
  final int empresaId;
  final String fecha;
  final String hora;
  final String tipo;
  final String? estudianteNombre;
}
