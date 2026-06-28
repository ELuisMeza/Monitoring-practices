import 'dart:io';

import 'package:following_practices/back/database/database_path_core.dart';
import 'package:path_provider/path_provider.dart';

/// Ruta de la BD para la app Flutter.
///
/// Regla: `{directorio_app}/data/following_practices.db`
/// - Windows / Linux / macOS: `{proyecto}/data/following_practices.db`
/// - Android / iOS: almacenamiento interno + `data/`
///   (en debug, importar desde `/data/local/tmp/` vía [DatabaseSync]).
class DatabasePath {
  DatabasePath._();

  static Future<String> resolve({
    String? override,
  }) async {
    if (override != null && override.isNotEmpty) {
      return override;
    }

    const fromEnv = String.fromEnvironment('DB_PATH');

    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }

    if (Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS) {
      final projectPath =
          DatabasePathCore.resolveProjectDatabasePath();

      if (projectPath != null) {
        return projectPath;
      }
    }

    final base = await _mobileBaseDirectory();

    return DatabasePathCore.buildPath(base.path);
  }

  static Future<Directory> _mobileBaseDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }

    return getApplicationSupportDirectory();
  }
}