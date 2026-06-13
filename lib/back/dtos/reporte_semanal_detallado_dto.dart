import 'package:following_practices/back/dtos/actividad_list_item_dto.dart';

/// Reporte semanal con desglose diario.
class ReporteSemanalDetalladoDto {
  const ReporteSemanalDetalladoDto({
    required this.estudianteId,
    required this.practicaId,
    required this.totalHoras,
    required this.cantidadActividades,
    required this.fechaInicio,
    required this.fechaFin,
    required this.actividades,
    required this.horasPorDia,
  });

  final int estudianteId;
  final int practicaId;
  final double totalHoras;
  final int cantidadActividades;
  final String fechaInicio;
  final String fechaFin;
  final List<ActividadListItemDto> actividades;
  final Map<String, double> horasPorDia;
}
