import 'package:following_practices/back/entities/entity_database.dart';

/// Mapeo de la tabla `asistencias`.
class Asistencia {
  const Asistencia({
    this.id,
    required this.practicaId,
    required this.empresaId,
    required this.fecha,
    required this.hora,
    required this.tipo,
    this.createdAt,
  });

  static const tableName = 'asistencias';

  static const tipoEntrada = 'entrada';
  static const tipoSalida = 'salida';

  final int? id;
  final int practicaId;
  final int empresaId;
  final String fecha;
  final String hora;
  final String tipo;
  final String? createdAt;

  factory Asistencia.fromMap(Map<String, dynamic> map) {
    return Asistencia(
      id: map['id'] as int?,
      practicaId: map['practica_id'] as int,
      empresaId: map['empresa_id'] as int,
      fecha: map['fecha'] as String,
      hora: map['hora'] as String,
      tipo: map['tipo'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'practica_id': practicaId,
      'empresa_id': empresaId,
      'fecha': fecha,
      'hora': hora,
      'tipo': tipo,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  Future<Asistencia> create() async {
    final newId = await EntityDatabase.insert(tableName, mapForInsert(toMap()));
    return Asistencia.fromMap({...toMap(), 'id': newId});
  }

  static Future<Asistencia?> read(int id) async {
    final row = await EntityDatabase.findById(tableName, id);
    return row == null ? null : Asistencia.fromMap(row);
  }

  static Future<List<Asistencia>> readAll({
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
    return rows.map(Asistencia.fromMap).toList();
  }

  Future<int> update() async {
    if (id == null) {
      throw StateError('No se puede actualizar una asistencia sin id.');
    }
    return EntityDatabase.updateById(tableName, mapForUpdate(toMap()), id!);
  }

  Future<int> delete() async {
    if (id == null) {
      throw StateError('No se puede eliminar una asistencia sin id.');
    }
    return EntityDatabase.deleteById(tableName, id!);
  }

  static Future<List<Asistencia>> readByPracticaFecha(
    int practicaId,
    String fecha,
  ) {
    return readAll(
      where: 'practica_id = ? AND fecha = ?',
      whereArgs: [practicaId, fecha],
      orderBy: 'hora ASC',
    );
  }

  static Future<List<Asistencia>> readByEmpresaFecha(
    int empresaId,
    String fecha,
  ) {
    return readAll(
      where: 'empresa_id = ? AND fecha = ?',
      whereArgs: [empresaId, fecha],
      orderBy: 'hora ASC',
    );
  }
}
