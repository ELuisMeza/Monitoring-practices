import 'package:following_practices/back/entities/entity_database.dart';

/// Mapeo de la tabla `historial_estados`.
class HistorialEstado {
  const HistorialEstado({
    this.id,
    required this.actividadId,
    required this.usuarioId,
    this.estadoAnterior,
    required this.estadoNuevo,
    this.createdAt,
  });

  static const tableName = 'historial_estados';

  final int? id;
  final int actividadId;
  final int usuarioId;
  final String? estadoAnterior;
  final String estadoNuevo;
  final String? createdAt;

  factory HistorialEstado.fromMap(Map<String, dynamic> map) {
    return HistorialEstado(
      id: map['id'] as int?,
      actividadId: map['actividad_id'] as int,
      usuarioId: map['usuario_id'] as int,
      estadoAnterior: map['estado_anterior'] as String?,
      estadoNuevo: map['estado_nuevo'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'actividad_id': actividadId,
      'usuario_id': usuarioId,
      'estado_anterior': estadoAnterior,
      'estado_nuevo': estadoNuevo,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  Future<HistorialEstado> create() async {
    final newId = await EntityDatabase.insert(tableName, mapForInsert(toMap()));
    return HistorialEstado.fromMap({...toMap(), 'id': newId});
  }

  static Future<List<HistorialEstado>> readByActividadId(int actividadId) {
    return readAll(
      where: 'actividad_id = ?',
      whereArgs: [actividadId],
      orderBy: 'created_at ASC',
    );
  }

  static Future<List<HistorialEstado>> readAll({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final rows = await EntityDatabase.findAll(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
    return rows.map(HistorialEstado.fromMap).toList();
  }
}
