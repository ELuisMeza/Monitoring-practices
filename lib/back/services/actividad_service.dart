import 'package:following_practices/back/dtos/actividad_detalle_dto.dart';
import 'package:following_practices/back/dtos/actividad_list_item_dto.dart';
import 'package:following_practices/back/dtos/observacion_dto.dart';
import 'package:following_practices/back/dtos/reporte_semanal_detallado_dto.dart';
import 'package:following_practices/back/dtos/resumen_horas_semanal_dto.dart';
import 'package:following_practices/back/entities/actividad.dart';
import 'package:following_practices/back/entities/historial_estado.dart';
import 'package:following_practices/back/entities/observacion.dart';
import 'package:following_practices/back/entities/practica.dart';
import 'package:following_practices/back/entities/usuario.dart';
import 'package:following_practices/back/validators/input_validator.dart';

/// Lógica de negocio de actividades (cálculos, reglas, agregaciones).
class ActividadService {
  Future<ResumenHorasSemanalDto?> calcularHorasUltimaSemana(int estudianteId) async {
    final practica = await Practica.readActivaByEstudianteId(estudianteId);
    if (practica == null || practica.id == null) return null;

    final hoy = DateTime.now();
    final inicio = hoy.subtract(const Duration(days: 7));
    final fechaInicio = InputValidator.formatoFecha(inicio);
    final fechaFin = InputValidator.formatoFecha(hoy);

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

  Future<ReporteSemanalDetalladoDto?> obtenerReporteSemanalDetallado(
    int estudianteId,
  ) async {
    final resumen = await calcularHorasUltimaSemana(estudianteId);
    if (resumen == null) return null;

    final actividades = await Actividad.readByPracticaEnRango(
      practicaId: resumen.practicaId,
      fechaInicio: resumen.fechaInicio,
      fechaFin: resumen.fechaFin,
    );

    final items = actividades
        .map(
          (a) => ActividadListItemDto(
            id: a.id!,
            fecha: a.fecha,
            descripcion: a.descripcion,
            horasCumplidas: a.horasCumplidas,
            estado: a.estado,
          ),
        )
        .toList();

    final horasPorDia = <String, double>{};
    for (final a in actividades) {
      horasPorDia[a.fecha] = (horasPorDia[a.fecha] ?? 0) + a.horasCumplidas;
    }

    return ReporteSemanalDetalladoDto(
      estudianteId: resumen.estudianteId,
      practicaId: resumen.practicaId,
      totalHoras: resumen.totalHoras,
      cantidadActividades: resumen.cantidadActividades,
      fechaInicio: resumen.fechaInicio,
      fechaFin: resumen.fechaFin,
      actividades: items,
      horasPorDia: horasPorDia,
    );
  }

  Future<Actividad> registrarActividad({
    required int estudianteId,
    required String fecha,
    required String descripcion,
    required double horasCumplidas,
    String? evidenciaUrl,
  }) async {
    final fechaError = InputValidator.fechaIso(fecha);
    if (fechaError != null) throw ArgumentError(fechaError);

    final descError = InputValidator.requiredText(descripcion, label: 'Descripción');
    if (descError != null) throw ArgumentError(descError);

    if (horasCumplidas <= 0) {
      throw ArgumentError('Las horas deben ser mayores a 0.');
    }

    final practica = await Practica.readActivaByEstudianteId(estudianteId);
    if (practica == null || practica.id == null) {
      throw StateError('No tienes una práctica activa.');
    }

    return Actividad(
      practicaId: practica.id!,
      fecha: fecha.trim(),
      descripcion: descripcion.trim(),
      horasCumplidas: horasCumplidas,
      evidenciaUrl: evidenciaUrl?.trim().isEmpty == true ? null : evidenciaUrl?.trim(),
      estado: Actividad.estadoRegistrado,
    ).create();
  }

  Future<List<ActividadListItemDto>> listarPorEstudiante(int estudianteId) async {
    final practica = await Practica.readActivaByEstudianteId(estudianteId);
    if (practica == null || practica.id == null) return [];

    final actividades = await Actividad.readByPracticaId(practica.id!);
    return actividades
        .map(
          (a) => ActividadListItemDto(
            id: a.id!,
            fecha: a.fecha,
            descripcion: a.descripcion,
            horasCumplidas: a.horasCumplidas,
            estado: a.estado,
          ),
        )
        .toList();
  }

  Future<List<ActividadListItemDto>> listarPendientesPorTutor(int tutorId) async {
    final practicas = await Practica.readByTutorId(tutorId);
    return _listarPendientes(practicas);
  }

  Future<List<ActividadListItemDto>> listarPendientesPorSupervisor(
    int supervisorId,
  ) async {
    final supervisor = await Usuario.read(supervisorId);
    if (supervisor == null || supervisor.empresaId == null) return [];

    final practicas = await Practica.readActivasByEmpresaId(supervisor.empresaId!);
    return _listarPendientes(practicas);
  }

  Future<List<ActividadListItemDto>> _listarPendientes(
    List<Practica> practicas,
  ) async {
    final ids = practicas.where((p) => p.id != null).map((p) => p.id!).toList();
    final actividades = await Actividad.readPendientesByPracticaIds(ids);

    final result = <ActividadListItemDto>[];
    for (final a in actividades) {
      final practica = practicas.firstWhere((p) => p.id == a.practicaId);
      final estudiante = await Usuario.read(practica.estudianteId);
      result.add(
        ActividadListItemDto(
          id: a.id!,
          fecha: a.fecha,
          descripcion: a.descripcion,
          horasCumplidas: a.horasCumplidas,
          estado: a.estado,
          estudianteNombre: estudiante?.nombre,
        ),
      );
    }
    return result;
  }

  Future<ActividadDetalleDto?> obtenerDetalle(int actividadId) async {
    final actividad = await Actividad.read(actividadId);
    if (actividad == null || actividad.id == null) return null;

    final practica = await Practica.read(actividad.practicaId);
    String? estudianteNombre;
    if (practica != null) {
      final estudiante = await Usuario.read(practica.estudianteId);
      estudianteNombre = estudiante?.nombre;
    }

    final observaciones = await Observacion.readByActividadId(actividad.id!);
    final obsDtos = <ObservacionDto>[];
    for (final o in observaciones) {
      final autor = await Usuario.read(o.usuarioId);
      obsDtos.add(
        ObservacionDto(
          id: o.id!,
          actividadId: o.actividadId,
          usuarioId: o.usuarioId,
          autorNombre: autor?.nombre ?? 'Usuario',
          texto: o.texto,
          createdAt: o.createdAt ?? '',
        ),
      );
    }

    return ActividadDetalleDto(
      id: actividad.id!,
      practicaId: actividad.practicaId,
      fecha: actividad.fecha,
      descripcion: actividad.descripcion,
      horasCumplidas: actividad.horasCumplidas,
      evidenciaUrl: actividad.evidenciaUrl,
      estado: actividad.estado,
      observaciones: obsDtos,
      estudianteNombre: estudianteNombre,
    );
  }

  Future<void> actualizarActividadEstudiante({
    required int actividadId,
    required int estudianteId,
    required String fecha,
    required String descripcion,
    required double horasCumplidas,
    String? evidenciaUrl,
  }) async {
    final actividad = await Actividad.read(actividadId);
    if (actividad == null) throw StateError('Actividad no encontrada.');

    final practica = await Practica.read(actividad.practicaId);
    if (practica == null || practica.estudianteId != estudianteId) {
      throw StateError('No autorizado.');
    }
    if (actividad.estado != Actividad.estadoRegistrado) {
      throw StateError('Solo puedes editar actividades en estado registrado.');
    }

    final actualizada = Actividad(
      id: actividad.id,
      practicaId: actividad.practicaId,
      fecha: fecha.trim(),
      descripcion: descripcion.trim(),
      horasCumplidas: horasCumplidas,
      evidenciaUrl: evidenciaUrl,
      estado: actividad.estado,
      createdAt: actividad.createdAt,
    );
    await actualizada.update();
  }

  Future<void> eliminarActividadEstudiante({
    required int actividadId,
    required int estudianteId,
  }) async {
    final actividad = await Actividad.read(actividadId);
    if (actividad == null) throw StateError('Actividad no encontrada.');

    final practica = await Practica.read(actividad.practicaId);
    if (practica == null || practica.estudianteId != estudianteId) {
      throw StateError('No autorizado.');
    }
    if (actividad.estado != Actividad.estadoRegistrado) {
      throw StateError('Solo puedes eliminar actividades en estado registrado.');
    }
    await actividad.delete();
  }

  Future<void> revisarActividad({
    required int actividadId,
    required int revisorId,
    required String nuevoEstado,
    required String observacionTexto,
  }) async {
    final estadoError = InputValidator.estadoActividad(nuevoEstado);
    if (estadoError != null) throw ArgumentError(estadoError);

    if (!{
      Actividad.estadoObservado,
      Actividad.estadoAprobado,
      Actividad.estadoRechazado,
    }.contains(nuevoEstado)) {
      throw ArgumentError('Estado de revisión inválido.');
    }

    final textoError = InputValidator.requiredText(observacionTexto, label: 'Observación');
    if (textoError != null) throw ArgumentError(textoError);

    final actividad = await Actividad.read(actividadId);
    if (actividad == null || actividad.id == null) {
      throw StateError('Actividad no encontrada.');
    }

    final estadoAnterior = actividad.estado;

    await Observacion(
      actividadId: actividad.id!,
      usuarioId: revisorId,
      texto: observacionTexto.trim(),
    ).create();

    final actualizada = Actividad(
      id: actividad.id,
      practicaId: actividad.practicaId,
      fecha: actividad.fecha,
      descripcion: actividad.descripcion,
      horasCumplidas: actividad.horasCumplidas,
      evidenciaUrl: actividad.evidenciaUrl,
      estado: nuevoEstado,
      createdAt: actividad.createdAt,
    );
    await actualizada.update();

    await HistorialEstado(
      actividadId: actividad.id!,
      usuarioId: revisorId,
      estadoAnterior: estadoAnterior,
      estadoNuevo: nuevoEstado,
    ).create();
  }
}
