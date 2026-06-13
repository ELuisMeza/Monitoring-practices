import 'package:following_practices/back/dtos/actividad_detalle_dto.dart';
import 'package:following_practices/back/dtos/actividad_list_item_dto.dart';
import 'package:following_practices/back/dtos/reporte_semanal_detallado_dto.dart';
import 'package:following_practices/back/dtos/resumen_horas_semanal_dto.dart';
import 'package:following_practices/back/entities/actividad.dart';
import 'package:following_practices/front/lib/service_locator.dart';

class ActividadService {
  Future<ResumenHorasSemanalDto?> obtenerHorasUltimaSemana(int estudianteId) {
    return ServiceLocator.actividad.calcularHorasUltimaSemana(estudianteId);
  }

  Future<ReporteSemanalDetalladoDto?> obtenerReporteSemanal(int estudianteId) {
    return ServiceLocator.actividad.obtenerReporteSemanalDetallado(estudianteId);
  }

  Future<Actividad> registrar({
    required int estudianteId,
    required String fecha,
    required String descripcion,
    required double horasCumplidas,
    String? evidenciaUrl,
  }) {
    return ServiceLocator.actividad.registrarActividad(
      estudianteId: estudianteId,
      fecha: fecha,
      descripcion: descripcion,
      horasCumplidas: horasCumplidas,
      evidenciaUrl: evidenciaUrl,
    );
  }

  Future<List<ActividadListItemDto>> listarPorEstudiante(int estudianteId) {
    return ServiceLocator.actividad.listarPorEstudiante(estudianteId);
  }

  Future<List<ActividadListItemDto>> listarPendientesTutor(int tutorId) {
    return ServiceLocator.actividad.listarPendientesPorTutor(tutorId);
  }

  Future<List<ActividadListItemDto>> listarPendientesSupervisor(int supervisorId) {
    return ServiceLocator.actividad.listarPendientesPorSupervisor(supervisorId);
  }

  Future<ActividadDetalleDto?> obtenerDetalle(int actividadId) {
    return ServiceLocator.actividad.obtenerDetalle(actividadId);
  }

  Future<void> revisar({
    required int actividadId,
    required int revisorId,
    required String nuevoEstado,
    required String observacion,
  }) {
    return ServiceLocator.actividad.revisarActividad(
      actividadId: actividadId,
      revisorId: revisorId,
      nuevoEstado: nuevoEstado,
      observacionTexto: observacion,
    );
  }
}
