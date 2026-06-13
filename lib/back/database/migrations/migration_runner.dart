import 'package:following_practices/back/database/database_constants.dart';
import 'package:following_practices/back/database/migrations/migration.dart';
import 'package:following_practices/back/database/migrations/migration_001_initial.dart';
import 'package:following_practices/back/database/migrations/migration_002_alertas_historial.dart';
import 'package:following_practices/back/database/migrations/migration_003_seed_demo.dart';
import 'package:following_practices/back/database/migrations/migration_004_ensure_demo_users.dart';
import 'package:following_practices/back/database/migrations/migration_005_supervisor_empresa.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Ejecuta migraciones pendientes en orden ascendente de versión.
class MigrationRunner {
  MigrationRunner._();

  static final List<Migration> _migrations = [
    Migration001Initial(),
    Migration002AlertasHistorial(),
    Migration003SeedDemo(),
    Migration004EnsureDemoUsers(),
    Migration005SupervisorEmpresa(),
  ];

  static Future<List<int>> run(Database db) async {
    await db.execute(InitialSchemaMigrationsDDL.createTable);

    final appliedVersions = await _getAppliedVersions(db);
    final pending = _migrations
        .where((migration) => !appliedVersions.contains(migration.version))
        .toList()
      ..sort((a, b) => a.version.compareTo(b.version));

    final executed = <int>[];

    for (final migration in pending) {
      await db.transaction((txn) async {
        await migration.up(txn);
        await txn.insert(DatabaseConstants.tableSchemaMigrations, {
          'version': migration.version,
          'name': migration.name,
        });
      });
      executed.add(migration.version);
    }

    return executed;
  }

  static Future<Set<int>> _getAppliedVersions(Database db) async {
    final rows = await db.query(
      DatabaseConstants.tableSchemaMigrations,
      columns: ['version'],
    );
    return rows.map((row) => row['version'] as int).toSet();
  }
}

/// DDL mínimo para la tabla de control de migraciones.
class InitialSchemaMigrationsDDL {
  InitialSchemaMigrationsDDL._();

  static const String createTable = '''
CREATE TABLE IF NOT EXISTS schema_migrations (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    version    INTEGER NOT NULL UNIQUE,
    name       TEXT    NOT NULL,
    applied_at TEXT    DEFAULT (datetime('now'))
);
''';
}
