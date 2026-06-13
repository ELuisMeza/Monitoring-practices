import 'package:following_practices/back/dtos/asistencia_dto.dart';
import 'package:following_practices/back/entities/asistencia.dart';
import 'package:following_practices/back/entities/empresa.dart';
import 'package:following_practices/back/entities/practica.dart';
import 'package:following_practices/back/entities/usuario.dart';
import 'package:following_practices/back/validators/input_validator.dart';

/// Lógica de negocio de asistencia por QR.
class AsistenciaService {
  Future<Asistencia> registrarPorQr({
    required int estudianteId,
    required String qrToken,
  }) async {
    if (qrToken.trim().isEmpty) {
      throw ArgumentError('Token QR inválido.');
    }

    final empresa = await Empresa.readByQrToken(qrToken.trim());
    if (empresa == null || empresa.id == null) {
      throw StateError('QR no reconocido.');
    }

    final practica = await Practica.readActivaByEstudianteId(estudianteId);
    if (practica == null || practica.id == null) {
      throw StateError('No tienes práctica activa.');
    }
    if (practica.empresaId != empresa.id) {
      throw StateError('Este QR no corresponde a tu empresa de práctica.');
    }

    final ahora = DateTime.now();
    final fecha = InputValidator.formatoFecha(ahora);
    final hora = InputValidator.formatoHora(ahora);

    final delDia = await Asistencia.readByPracticaFecha(practica.id!, fecha);
    final tieneEntrada = delDia.any((a) => a.tipo == Asistencia.tipoEntrada);
    final tieneSalida = delDia.any((a) => a.tipo == Asistencia.tipoSalida);

    String tipo;
    if (!tieneEntrada) {
      tipo = Asistencia.tipoEntrada;
    } else if (!tieneSalida) {
      tipo = Asistencia.tipoSalida;
    } else {
      throw StateError('Ya registraste entrada y salida hoy.');
    }

    return Asistencia(
      practicaId: practica.id!,
      empresaId: empresa.id!,
      fecha: fecha,
      hora: hora,
      tipo: tipo,
    ).create();
  }

  Future<List<AsistenciaDto>> listarPorEstudianteHoy(int estudianteId) async {
    final practica = await Practica.readActivaByEstudianteId(estudianteId);
    if (practica == null || practica.id == null) return [];

    final fecha = InputValidator.formatoFecha(DateTime.now());
    final asistencias = await Asistencia.readByPracticaFecha(practica.id!, fecha);
    return asistencias
        .map(
          (a) => AsistenciaDto(
            id: a.id!,
            practicaId: a.practicaId,
            empresaId: a.empresaId,
            fecha: a.fecha,
            hora: a.hora,
            tipo: a.tipo,
          ),
        )
        .toList();
  }

  Future<List<AsistenciaDto>> listarPorSupervisorHoy(int supervisorId) async {
    final supervisor = await Usuario.read(supervisorId);
    if (supervisor == null || supervisor.empresaId == null) return [];

    final fecha = InputValidator.formatoFecha(DateTime.now());
    final asistencias = await Asistencia.readByEmpresaFecha(
      supervisor.empresaId!,
      fecha,
    );

    final result = <AsistenciaDto>[];
    for (final a in asistencias) {
      final practica = await Practica.read(a.practicaId);
      String? estudianteNombre;
      if (practica != null) {
        final estudiante = await Usuario.read(practica.estudianteId);
        estudianteNombre = estudiante?.nombre;
      }
      result.add(
        AsistenciaDto(
          id: a.id!,
          practicaId: a.practicaId,
          empresaId: a.empresaId,
          fecha: a.fecha,
          hora: a.hora,
          tipo: a.tipo,
          estudianteNombre: estudianteNombre,
        ),
      );
    }
    return result;
  }
}
