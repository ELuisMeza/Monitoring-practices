import 'package:following_practices/back/database/database_factory.dart';
import 'package:following_practices/back/database/database_path.dart';
import 'package:following_practices/back/database/database_sync.dart';

/// Orquesta la inicialización de servicios al arrancar la app.
///
/// Solo abre SQLite. Para crear/actualizar tablas: `dart run bin/migrate.dart`.
class AppInitializerService {
  AppInitializerService._();

  static Future<void> initialize() async {
    final dbPath = await DatabasePath.resolve();
    await DatabaseSync.importFromTmpIfNeeded(dbPath);
    await DatabaseFactory.apiClient.initialize(databasePath: dbPath);
  }
}
