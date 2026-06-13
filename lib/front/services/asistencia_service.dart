import 'package:following_practices/back/dtos/asistencia_dto.dart';
import 'package:following_practices/back/entities/asistencia.dart';
import 'package:following_practices/front/lib/service_locator.dart';

class AsistenciaService {
  Future<Asistencia> registrarPorQr({
    required int estudianteId,
    required String qrToken,
  }) {
    return ServiceLocator.asistencia.registrarPorQr(
      estudianteId: estudianteId,
      qrToken: qrToken,
    );
  }

  Future<List<AsistenciaDto>> listarHoyEstudiante(int estudianteId) {
    return ServiceLocator.asistencia.listarPorEstudianteHoy(estudianteId);
  }

  Future<List<AsistenciaDto>> listarHoySupervisor(int supervisorId) {
    return ServiceLocator.asistencia.listarPorSupervisorHoy(supervisorId);
  }
}
