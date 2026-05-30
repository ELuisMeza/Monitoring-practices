import 'package:following_practices/back/database/database_factory.dart';

/// Orquesta la inicialización de servicios al arrancar la app.
class AppInitializerService {
  AppInitializerService._();

  static Future<void> initialize() async {
    await DatabaseFactory.apiClient.initialize();
  }
}
