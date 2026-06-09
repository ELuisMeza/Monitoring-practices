import 'package:following_practices/back/entities/entity_database.dart';

/// Mapeo de la tabla `actividades`.
class Actividad {
  const Actividad({
    this.id,
    required this.practicaId,
    required this.fecha,
    required this.descripcion,
    required this.horasCumplidas,
    this.evidenciaUrl,
    required this.estado,
    this.createdAt,
  });

  static const tableName = 'actividades';

  static const estadoRegistrado = 'registrado';
  static const estadoObservado = 'observado';
  static const estadoAprobado = 'aprobado';
  static const estadoRechazado = 'rechazado';

  final int? id;
  final int practicaId;
  final String fecha;
  final String descripcion;
  final double horasCumplidas;
  final String? evidenciaUrl;
  final String estado;
  final String? createdAt;

  factory Actividad.fromMap(Map<String, dynamic> map) {
    return Actividad(
      id: map['id'] as int?,
      practicaId: map['practica_id'] as int,
      fecha: map['fecha'] as String,
      descripcion: map['descripcion'] as String,
      horasCumplidas: (map['horas_cumplidas'] as num).toDouble(),
      evidenciaUrl: map['evidencia_url'] as String?,
      estado: map['estado'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'practica_id': practicaId,
      'fecha': fecha,
      'descripcion': descripcion,
      'horas_cumplidas': horasCumplidas,
      'evidencia_url': evidenciaUrl,
      'estado': estado,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  Future<Actividad> create() async {
    final newId = await EntityDatabase.insert(tableName, mapForInsert(toMap()));
    return Actividad.fromMap({...toMap(), 'id': newId});
  }

  static Future<Actividad?> read(int id) async {
    final row = await EntityDatabase.findById(tableName, id);
    return row == null ? null : Actividad.fromMap(row);
  }

  static Future<List<Actividad>> readAll({
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
    return rows.map(Actividad.fromMap).toList();
  }

  Future<int> update() async {
    if (id == null) {
      throw StateError('No se puede actualizar una actividad sin id.');
    }
    return EntityDatabase.updateById(tableName, mapForUpdate(toMap()), id!);
  }

  Future<int> delete() async {
    if (id == null) {
      throw StateError('No se puede eliminar una actividad sin id.');
    }
    return EntityDatabase.deleteById(tableName, id!);
  }

  /// Actividades de una práctica en un rango de fechas (YYYY-MM-DD).
  static Future<List<Actividad>> readByPracticaEnRango({
    required int practicaId,
    required String fechaInicio,
    required String fechaFin,
  }) {
    return readAll(
      where: 'practica_id = ? AND fecha BETWEEN ? AND ?',
      whereArgs: [practicaId, fechaInicio, fechaFin],
      orderBy: 'fecha DESC',
    );
  }
}
