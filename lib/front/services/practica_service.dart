import 'package:following_practices/back/dtos/practica_resumen_dto.dart';
import 'package:following_practices/back/dtos/supervisor_alcance_dto.dart';
import 'package:following_practices/back/entities/practica.dart';
import 'package:following_practices/front/lib/service_locator.dart';

class PracticaService {
  Future<PracticaResumenDto?> obtenerPracticaActiva(int estudianteId) {
    return ServiceLocator.practica.obtenerPracticaActivaEstudiante(estudianteId);
  }

  Future<List<Practica>> listarPracticasPorSupervisor(int supervisorId) {
    return ServiceLocator.practica.listarPracticasPorSupervisor(supervisorId);
  }

  Future<SupervisorAlcanceDto> obtenerAlcanceSupervisor(int supervisorId) {
    return ServiceLocator.practica.obtenerAlcanceSupervisor(supervisorId);
  }
}
