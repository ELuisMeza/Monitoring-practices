/// DTO de respuesta: horas acumuladas de un estudiante en los últimos 7 días.
///
/// Lo construye [ActividadService] a partir de varias filas de `actividades`.
/// No es una tabla ni un entity.
class ResumenHorasSemanalDto {
  const ResumenHorasSemanalDto({
    required this.estudianteId,
    required this.practicaId,
    required this.totalHoras,
    required this.cantidadActividades,
    required this.fechaInicio,
    required this.fechaFin,
  });

  final int estudianteId;
  final int practicaId;
  final double totalHoras;
  final int cantidadActividades;
  final String fechaInicio;
  final String fechaFin;
}
