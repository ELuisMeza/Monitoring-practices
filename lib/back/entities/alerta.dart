import 'package:following_practices/back/entities/entity_database.dart';

/// Mapeo de la tabla `alertas`.
class Alerta {
  const Alerta({
    this.id,
    required this.usuarioId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.leida,
    this.createdAt,
  });

  static const tableName = 'alertas';

  static const tipoHorasBajas = 'horas_bajas';
  static const tipoPendientesRevision = 'pendientes_revision';
  static const tipoPracticaPorVencer = 'practica_por_vencer';

  final int? id;
  final int usuarioId;
  final String tipo;
  final String titulo;
  final String mensaje;
  final bool leida;
  final String? createdAt;

  factory Alerta.fromMap(Map<String, dynamic> map) {
    return Alerta(
      id: map['id'] as int?,
      usuarioId: map['usuario_id'] as int,
      tipo: map['tipo'] as String,
      titulo: map['titulo'] as String,
      mensaje: map['mensaje'] as String,
      leida: (map['leida'] as int) == 1,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'usuario_id': usuarioId,
      'tipo': tipo,
      'titulo': titulo,
      'mensaje': mensaje,
      'leida': leida ? 1 : 0,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  Future<Alerta> create() async {
    final newId = await EntityDatabase.insert(tableName, mapForInsert(toMap()));
    return Alerta.fromMap({...toMap(), 'id': newId});
  }

  static Future<List<Alerta>> readByUsuarioId(int usuarioId) {
    return readAll(
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'created_at DESC',
    );
  }

  static Future<List<Alerta>> readAll({
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
    return rows.map(Alerta.fromMap).toList();
  }

  Future<int> update() async {
    if (id == null) {
      throw StateError('No se puede actualizar una alerta sin id.');
    }
    return EntityDatabase.updateById(tableName, mapForUpdate(toMap()), id!);
  }
}
