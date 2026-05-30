import 'package:following_practices/back/database/migrations/migration.dart';
import 'package:following_practices/back/database/schema/initial_schema.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Migración inicial: crea las 6 tablas del dominio.
class Migration001Initial extends Migration {
  @override
  int get version => 1;

  @override
  String get name => 'initial_schema';

  @override
  Future<void> up(DatabaseExecutor db) async {
    final batch = db.batch();
    for (final statement in InitialSchema.domainStatements) {
      batch.execute(statement);
    }
    await batch.commit(noResult: true);
  }
}
