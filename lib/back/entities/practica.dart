import 'package:following_practices/back/entities/entity_database.dart';

/// Mapeo de la tabla `practicas`.
class Practica {
  const Practica({
    this.id,
    required this.estudianteId,
    required this.empresaId,
    this.tutorId,
    this.supervisorId,
    required this.fechaInicio,
    this.fechaFin,
    required this.horasRequeridas,
    required this.estado,
    this.createdAt,
  });

  static const tableName = 'practicas';

  static const estadoActiva = 'activa';
  static const estadoCompletada = 'completada';
  static const estadoSuspendida = 'suspendida';

  final int? id;
  final int estudianteId;
  final int empresaId;
  final int? tutorId;
  final int? supervisorId;
  final String fechaInicio;
  final String? fechaFin;
  final int horasRequeridas;
  final String estado;
  final String? createdAt;

  factory Practica.fromMap(Map<String, dynamic> map) {
    return Practica(
      id: map['id'] as int?,
      estudianteId: map['estudiante_id'] as int,
      empresaId: map['empresa_id'] as int,
      tutorId: map['tutor_id'] as int?,
      supervisorId: map['supervisor_id'] as int?,
      fechaInicio: map['fecha_inicio'] as String,
      fechaFin: map['fecha_fin'] as String?,
      horasRequeridas: map['horas_requeridas'] as int,
      estado: map['estado'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'estudiante_id': estudianteId,
      'empresa_id': empresaId,
      'tutor_id': tutorId,
      'supervisor_id': supervisorId,
      'fecha_inicio': fechaInicio,
      'fecha_fin': fechaFin,
      'horas_requeridas': horasRequeridas,
      'estado': estado,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  Future<Practica> create() async {
    final newId = await EntityDatabase.insert(tableName, mapForInsert(toMap()));
    return Practica.fromMap({...toMap(), 'id': newId});
  }

  static Future<Practica?> read(int id) async {
    final row = await EntityDatabase.findById(tableName, id);
    return row == null ? null : Practica.fromMap(row);
  }

  static Future<List<Practica>> readAll({
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
    return rows.map(Practica.fromMap).toList();
  }

  Future<int> update() async {
    if (id == null) {
      throw StateError('No se puede actualizar una práctica sin id.');
    }
    return EntityDatabase.updateById(tableName, mapForUpdate(toMap()), id!);
  }

  Future<int> delete() async {
    if (id == null) {
      throw StateError('No se puede eliminar una práctica sin id.');
    }
    return EntityDatabase.deleteById(tableName, id!);
  }

  static Future<Practica?> readActivaByEstudianteId(int estudianteId) async {
    final practicas = await readAll(
      where: 'estudiante_id = ? AND estado = ?',
      whereArgs: [estudianteId, estadoActiva],
      limit: 1,
    );
    return practicas.isEmpty ? null : practicas.first;
  }

  static Future<List<Practica>> readByTutorId(int tutorId) {
    return readAll(
      where: 'tutor_id = ? AND estado = ?',
      whereArgs: [tutorId, estadoActiva],
      orderBy: 'fecha_inicio DESC',
    );
  }

  static Future<List<Practica>> readBySupervisorId(int supervisorId) {
    return readAll(
      where: 'supervisor_id = ? AND estado = ?',
      whereArgs: [supervisorId, estadoActiva],
      orderBy: 'fecha_inicio DESC',
    );
  }

  static Future<List<Practica>> readActivasByEmpresaId(int empresaId) {
    return readAll(
      where: 'empresa_id = ? AND estado = ?',
      whereArgs: [empresaId, estadoActiva],
      orderBy: 'fecha_inicio DESC',
    );
  }

  static Future<List<Practica>> readAllActivas() {
    return readAll(
      where: 'estado = ?',
      whereArgs: [estadoActiva],
      orderBy: 'fecha_inicio DESC',
    );
  }
}
