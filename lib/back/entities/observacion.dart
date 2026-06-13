import 'package:following_practices/back/entities/entity_database.dart';

/// Mapeo de la tabla `observaciones`.
class Observacion {
  const Observacion({
    this.id,
    required this.actividadId,
    required this.usuarioId,
    required this.texto,
    this.createdAt,
  });

  static const tableName = 'observaciones';

  final int? id;
  final int actividadId;
  final int usuarioId;
  final String texto;
  final String? createdAt;

  factory Observacion.fromMap(Map<String, dynamic> map) {
    return Observacion(
      id: map['id'] as int?,
      actividadId: map['actividad_id'] as int,
      usuarioId: map['usuario_id'] as int,
      texto: map['texto'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'actividad_id': actividadId,
      'usuario_id': usuarioId,
      'texto': texto,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  Future<Observacion> create() async {
    final newId = await EntityDatabase.insert(tableName, mapForInsert(toMap()));
    return Observacion.fromMap({...toMap(), 'id': newId});
  }

  static Future<Observacion?> read(int id) async {
    final row = await EntityDatabase.findById(tableName, id);
    return row == null ? null : Observacion.fromMap(row);
  }

  static Future<List<Observacion>> readAll({
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
    return rows.map(Observacion.fromMap).toList();
  }

  Future<int> update() async {
    if (id == null) {
      throw StateError('No se puede actualizar una observación sin id.');
    }
    return EntityDatabase.updateById(tableName, mapForUpdate(toMap()), id!);
  }

  Future<int> delete() async {
    if (id == null) {
      throw StateError('No se puede eliminar una observación sin id.');
    }
    return EntityDatabase.deleteById(tableName, id!);
  }

  static Future<List<Observacion>> readByActividadId(int actividadId) {
    return readAll(
      where: 'actividad_id = ?',
      whereArgs: [actividadId],
      orderBy: 'created_at ASC',
    );
  }
}
