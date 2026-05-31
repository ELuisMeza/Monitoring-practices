import 'dart:io';

import 'package:following_practices/back/database/database_constants.dart';
import 'package:path/path.dart' as p;

/// Lógica compartida para resolver `{base}/data/following_practices.db`.
class DatabasePathCore {
  DatabasePathCore._();

  /// Ruta compartida en el emulador Android (debug) sincronizable con `adb push/pull`.
  static const String debugAndroidSharedPath =
      '/data/local/tmp/following_practices.db';

  static String buildPath(String baseDirectory) {
    final dataDir = Directory(
      p.join(baseDirectory, DatabaseConstants.storageDir),
    );
    if (!dataDir.existsSync()) {
      dataDir.createSync(recursive: true);
    }
    return p.join(dataDir.path, DatabaseConstants.dbName);
  }

  /// Busca la raíz del proyecto (directorio con `pubspec.yaml`).
  static String? findProjectRoot({String? startPath}) {
    var dir = Directory(startPath ?? Directory.current.path);

    for (var i = 0; i < 12; i++) {
      if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
        return dir.path;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    return null;
  }

  /// `{proyecto}/data/following_practices.db` cuando se detecta la raíz.
  static String? resolveProjectDatabasePath({String? startPath}) {
    final root = findProjectRoot(startPath: startPath);
    if (root == null) return null;
    return buildPath(root);
  }
}
