import 'package:following_practices/back/database/database_api_client.dart';

/// Factory responsable de proveer la instancia única de [DatabaseApiClient].
class DatabaseFactory {
  DatabaseFactory._();

  static DatabaseApiClient? _instance;

  /// Obtiene el cliente de base de datos (singleton).
  static DatabaseApiClient get apiClient {
    _instance ??= DatabaseApiClient();
    return _instance!;
  }

  /// Reinicia la instancia. Útil en pruebas.
  static Future<void> reset() async {
    if (_instance?.isInitialized ?? false) {
      await _instance!.close();
    }
    _instance = null;
  }
}
