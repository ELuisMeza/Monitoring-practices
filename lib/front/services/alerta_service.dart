import 'package:following_practices/back/dtos/alerta_dto.dart';
import 'package:following_practices/front/lib/service_locator.dart';

class AlertaService {
  Future<List<AlertaDto>> listar(int usuarioId) {
    return ServiceLocator.alerta.listarPorUsuario(usuarioId);
  }

  Future<void> marcarLeida(int alertaId) {
    return ServiceLocator.alerta.marcarLeida(alertaId);
  }

  Future<void> evaluarEstudiante(int estudianteId) {
    return ServiceLocator.alerta.evaluarAlertasEstudiante(estudianteId);
  }

  Future<void> evaluarRevisor(int revisorId, int pendientes) {
    return ServiceLocator.alerta.evaluarAlertasRevisor(revisorId, pendientes);
  }
}
