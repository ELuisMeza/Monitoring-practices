import 'package:following_practices/back/dtos/alerta_dto.dart';
import 'package:following_practices/back/entities/actividad.dart';
import 'package:following_practices/back/entities/alerta.dart';
import 'package:following_practices/back/entities/practica.dart';
import 'package:following_practices/back/validators/input_validator.dart';

/// Generación y consulta de alertas de avance.
class AlertaService {
  Future<List<AlertaDto>> listarPorUsuario(int usuarioId) async {
    final alertas = await Alerta.readByUsuarioId(usuarioId);
    return alertas
        .map(
          (a) => AlertaDto(
            id: a.id!,
            usuarioId: a.usuarioId,
            tipo: a.tipo,
            titulo: a.titulo,
            mensaje: a.mensaje,
            leida: a.leida,
            createdAt: a.createdAt ?? '',
          ),
        )
        .toList();
  }

  Future<void> marcarLeida(int alertaId) async {
    final alertas = await Alerta.readAll(
      where: 'id = ?',
      whereArgs: [alertaId],
      limit: 1,
    );
    if (alertas.isEmpty) return;
    final alerta = alertas.first;
    await Alerta(
      id: alerta.id,
      usuarioId: alerta.usuarioId,
      tipo: alerta.tipo,
      titulo: alerta.titulo,
      mensaje: alerta.mensaje,
      leida: true,
      createdAt: alerta.createdAt,
    ).update();
  }

  /// Evalúa y crea alertas para un estudiante según su avance.
  Future<void> evaluarAlertasEstudiante(int estudianteId) async {
    final practica = await Practica.readActivaByEstudianteId(estudianteId);
    if (practica == null || practica.id == null) return;

    final hoy = DateTime.now();
    final inicio = hoy.subtract(const Duration(days: 7));
    final actividades = await Actividad.readByPracticaEnRango(
      practicaId: practica.id!,
      fechaInicio: InputValidator.formatoFecha(inicio),
      fechaFin: InputValidator.formatoFecha(hoy),
    );

    var horasSemana = 0.0;
    for (final a in actividades) {
      horasSemana += a.horasCumplidas;
    }

    if (horasSemana < 20) {
      await _crearSiNoExiste(
        usuarioId: estudianteId,
        tipo: Alerta.tipoHorasBajas,
        titulo: 'Horas semanales bajas',
        mensaje: 'Llevas ${horasSemana.toStringAsFixed(1)} h esta semana. Meta sugerida: 20 h.',
      );
    }

    if (practica.fechaFin != null) {
      final fin = DateTime.parse(practica.fechaFin!);
      final diasRestantes = fin.difference(hoy).inDays;
      if (diasRestantes >= 0 && diasRestantes <= 14) {
        await _crearSiNoExiste(
          usuarioId: estudianteId,
          tipo: Alerta.tipoPracticaPorVencer,
          titulo: 'Práctica por vencer',
          mensaje: 'Tu práctica termina en $diasRestantes días.',
        );
      }
    }
  }

  Future<void> evaluarAlertasRevisor(int revisorId, int pendientes) async {
    if (pendientes > 0) {
      await _crearSiNoExiste(
        usuarioId: revisorId,
        tipo: Alerta.tipoPendientesRevision,
        titulo: 'Actividades pendientes',
        mensaje: 'Tienes $pendientes actividad(es) por revisar.',
      );
    }
  }

  Future<void> _crearSiNoExiste({
    required int usuarioId,
    required String tipo,
    required String titulo,
    required String mensaje,
  }) async {
    final existentes = await Alerta.readAll(
      where: 'usuario_id = ? AND tipo = ? AND leida = 0',
      whereArgs: [usuarioId, tipo],
      limit: 1,
    );
    if (existentes.isNotEmpty) return;

    await Alerta(
      usuarioId: usuarioId,
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      leida: false,
    ).create();
  }
}
