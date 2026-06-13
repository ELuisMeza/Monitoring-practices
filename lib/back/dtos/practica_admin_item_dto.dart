/// Práctica para administración del coordinador.
class PracticaAdminItemDto {
  const PracticaAdminItemDto({
    required this.id,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.empresaId,
    required this.empresaNombre,
    this.tutorId,
    this.tutorNombre,
    this.supervisorId,
    this.supervisorNombre,
    required this.fechaInicio,
    this.fechaFin,
    required this.horasRequeridas,
    required this.estado,
  });

  final int id;
  final int estudianteId;
  final String estudianteNombre;
  final int empresaId;
  final String empresaNombre;
  final int? tutorId;
  final String? tutorNombre;
  final int? supervisorId;
  final String? supervisorNombre;
  final String fechaInicio;
  final String? fechaFin;
  final int horasRequeridas;
  final String estado;
}
