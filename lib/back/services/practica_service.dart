import 'package:following_practices/back/dtos/practica_resumen_dto.dart';
import 'package:following_practices/back/dtos/supervisor_alcance_dto.dart';
import 'package:following_practices/back/entities/actividad.dart';
import 'package:following_practices/back/entities/empresa.dart';
import 'package:following_practices/back/entities/practica.dart';
import 'package:following_practices/back/entities/usuario.dart';

/// Lógica de negocio de prácticas preprofesionales.
class PracticaService {
  Future<PracticaResumenDto?> obtenerPracticaActivaEstudiante(
    int estudianteId,
  ) async {
    final practica = await Practica.readActivaByEstudianteId(estudianteId);
    if (practica == null || practica.id == null) return null;

    final empresa = await Empresa.read(practica.empresaId);
    if (empresa == null) return null;

    final horasAcumuladas = await Actividad.sumHorasByPracticaId(practica.id!);

    String? tutorNombre;
    String? supervisorNombre;
    if (practica.tutorId != null) {
      final tutor = await Usuario.read(practica.tutorId!);
      tutorNombre = tutor?.nombre;
    }
    if (practica.supervisorId != null) {
      final supervisor = await Usuario.read(practica.supervisorId!);
      supervisorNombre = supervisor?.nombre;
    }

    return PracticaResumenDto(
      practicaId: practica.id!,
      estudianteId: practica.estudianteId,
      empresaId: empresa.id!,
      empresaNombre: empresa.nombre,
      qrToken: empresa.qrToken,
      fechaInicio: practica.fechaInicio,
      fechaFin: practica.fechaFin,
      horasRequeridas: practica.horasRequeridas,
      horasAcumuladas: horasAcumuladas,
      tutorNombre: tutorNombre,
      supervisorNombre: supervisorNombre,
    );
  }

  Future<List<Practica>> listarPracticasPorTutor(int tutorId) {
    return Practica.readByTutorId(tutorId);
  }

  Future<List<Practica>> listarPracticasPorSupervisor(int supervisorId) async {
    final supervisor = await Usuario.read(supervisorId);
    if (supervisor == null || supervisor.empresaId == null) return [];
    return Practica.readActivasByEmpresaId(supervisor.empresaId!);
  }

  Future<List<Practica>> listarPracticasPorEmpresa(int empresaId) {
    return Practica.readActivasByEmpresaId(empresaId);
  }

  Future<List<Practica>> listarPracticasActivas() {
    return Practica.readAllActivas();
  }

  Future<SupervisorAlcanceDto> obtenerAlcanceSupervisor(int supervisorId) async {
    final supervisor = await Usuario.read(supervisorId);
    if (supervisor == null || supervisor.empresaId == null) {
      return const SupervisorAlcanceDto(practicantesActivos: 0);
    }

    final empresa = await Empresa.read(supervisor.empresaId!);
    final practicas = await Practica.readActivasByEmpresaId(supervisor.empresaId!);

    return SupervisorAlcanceDto(
      empresaNombre: empresa?.nombre,
      practicantesActivos: practicas.length,
    );
  }
}
