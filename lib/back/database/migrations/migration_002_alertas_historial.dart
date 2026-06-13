import 'package:following_practices/back/database/migrations/migration.dart';
import 'package:following_practices/back/database/schema/migration_002_schema.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Migración 002: tablas de alertas e historial de estados.
class Migration002AlertasHistorial extends Migration {
  @override
  int get version => 2;

  @override
  String get name => 'alertas_historial';

  @override
  Future<void> up(DatabaseExecutor db) async {
    final batch = db.batch();
    for (final statement in Migration002Schema.statements) {
      batch.execute(statement);
    }
    await batch.commit(noResult: true);
  }
}
