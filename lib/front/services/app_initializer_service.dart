import 'package:following_practices/back/database/database_factory.dart';

/// Orquesta la inicialización de servicios al arrancar la app.
///
/// Solo abre SQLite. Para crear/actualizar tablas: `dart run bin/migrate.dart`.
class AppInitializerService {  AppInitializerService._();

  static Future<void> initialize() async {
    await DatabaseFactory.apiClient.initialize();
  }
}
