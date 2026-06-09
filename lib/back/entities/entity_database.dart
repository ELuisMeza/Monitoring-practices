import 'package:following_practices/back/database/database_factory.dart';
import 'package:sqflite_common/sqlite_api.dart' show Database;

/// Acceso SQLite compartido. Solo debe usarse desde `back/entities/`.
class EntityDatabase {
  EntityDatabase._();

  static Database get _db => DatabaseFactory.apiClient.database;

  static Future<int> insert(String table, Map<String, dynamic> data) {
    return _db.insert(table, data);
  }

  static Future<Map<String, dynamic>?> findById(String table, int id) async {
    final rows = await _db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  static Future<List<Map<String, dynamic>>> findAll(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) {
    return _db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  static Future<int> updateById(
    String table,
    Map<String, dynamic> data,
    int id,
  ) {
    return _db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteById(String table, int id) {
    return _db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

/// Utilidades comunes para mapas de entities.
Map<String, dynamic> mapForInsert(Map<String, dynamic> map) {
  return Map<String, dynamic>.from(map)..remove('id');
}

Map<String, dynamic> mapForUpdate(Map<String, dynamic> map) {
  return Map<String, dynamic>.from(map)
    ..remove('id')
    ..remove('created_at');
}
