import 'package:following_practices/back/database/database_path_core.dart';

/// Ruta de la BD para el script CLI (sin dependencias Flutter).
///
/// Misma regla: `{proyecto}/data/following_practices.db`
class DatabasePathCli {
  DatabasePathCli._();

  static String resolve({String? override}) {
    if (override != null && override.isNotEmpty) return override;

    const fromEnv = String.fromEnvironment('DB_PATH');
    if (fromEnv.isNotEmpty) return fromEnv;

    final path = DatabasePathCore.resolveProjectDatabasePath();
    if (path != null) return path;

    throw StateError(
      'No se encontró pubspec.yaml. Ejecute el script desde la raíz del proyecto.',
    );
  }
}
