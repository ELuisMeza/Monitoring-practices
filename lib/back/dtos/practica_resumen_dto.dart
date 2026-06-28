/// Resumen de práctica activa con datos de empresa y progreso.
class PracticaResumenDto {
  const PracticaResumenDto({
    required this.practicaId,
    required this.estudianteId,
    required this.empresaId,
    required this.empresaNombre,
    required this.qrToken,
    required this.fechaInicio,
    this.fechaFin,
    required this.horasRequeridas,
    required this.horasAcumuladas,
    this.tutorNombre,
    this.supervisorNombre,
  });

  final int practicaId;

  final int estudianteId;

  final int empresaId;

  final String empresaNombre;

  final String qrToken;

  final String fechaInicio;

  final String? fechaFin;

  final int horasRequeridas;

  final double horasAcumuladas;

  final String? tutorNombre;

  final String? supervisorNombre;

  double get porcentajeAvance =>
      horasRequeridas > 0
          ? (horasAcumuladas / horasRequeridas * 100)
          : 0;
}