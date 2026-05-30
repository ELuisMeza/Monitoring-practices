import 'package:following_practices/back/dtos/resumen_horas_semanal_dto.dart';
import 'package:following_practices/back/services/actividad_service.dart' as back;

/// Puerta de entrada del front hacia la lógica de negocio del back.
///
/// Las pages solo deben usar servicios de `front/services`,
/// nunca servicios ni entities de `back/` directamente.
class ActividadService {
  ActividadService({back.ActividadService? actividadService})
      : _actividadService = actividadService ?? back.ActividadService();

  final back.ActividadService _actividadService;

  Future<ResumenHorasSemanalDto?> obtenerHorasUltimaSemana(int estudianteId) {
    return _actividadService.calcularHorasUltimaSemana(estudianteId);
  }
}
