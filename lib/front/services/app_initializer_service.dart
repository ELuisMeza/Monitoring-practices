import 'package:following_practices/back/database/database_factory.dart';
import 'package:following_practices/back/database/database_path.dart';
import 'package:following_practices/back/database/database_sync.dart';
import 'package:following_practices/back/database/migrations/migration_runner.dart';

/// Orquesta la inicialización de servicios al arrancar la app.
class AppInitializerService {
  AppInitializerService._();

  static Future<void> initialize() async {
    final dbPath = await DatabasePath.resolve();
    await DatabaseSync.importFromTmpIfNeeded(dbPath);
    await DatabaseFactory.apiClient.initialize(databasePath: dbPath);
    await MigrationRunner.run(DatabaseFactory.apiClient.database);
  }
}
