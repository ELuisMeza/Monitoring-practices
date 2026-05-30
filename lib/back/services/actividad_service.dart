import 'package:following_practices/back/dtos/resumen_horas_semanal_dto.dart';
import 'package:following_practices/back/entities/actividad.dart';
import 'package:following_practices/back/entities/practica.dart';

/// Lógica de negocio de actividades (cálculos, reglas, agregaciones).
///
/// Solo debe ser consumido desde `front/services`, no desde pages directamente al back.
class ActividadService {
  /// Calcula las horas cumplidas por un estudiante en los últimos 7 días.
  Future<ResumenHorasSemanalDto?> calcularHorasUltimaSemana(int estudianteId) async {
    final practica = await Practica.readActivaByEstudianteId(estudianteId);
    if (practica == null || practica.id == null) return null;

    final hoy = DateTime.now();
    final inicio = hoy.subtract(const Duration(days: 7));
    final fechaInicio = _formatoFecha(inicio);
    final fechaFin = _formatoFecha(hoy);

    final actividades = await Actividad.readByPracticaEnRango(
      practicaId: practica.id!,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );

    var totalHoras = 0.0;
    for (final actividad in actividades) {
      totalHoras += actividad.horasCumplidas;
    }

    return ResumenHorasSemanalDto(
      estudianteId: estudianteId,
      practicaId: practica.id!,
      totalHoras: totalHoras,
      cantidadActividades: actividades.length,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );
  }

  String _formatoFecha(DateTime fecha) {
    final y = fecha.year.toString().padLeft(4, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
