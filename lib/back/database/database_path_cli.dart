import 'dart:io';

import 'package:following_practices/back/database/database_constants.dart';
import 'package:path/path.dart' as p;

/// Ruta de la BD para el script CLI (sin dependencias Flutter).
///
/// Misma regla relativa: `{proyecto}/data/following_practices.db`
class DatabasePathCli {
  DatabasePathCli._();

  static String resolve({String? override}) {
    if (override != null && override.isNotEmpty) return override;

    final dataDir = Directory(
      p.join(Directory.current.path, DatabaseConstants.storageDir),
    );
    if (!dataDir.existsSync()) {
      dataDir.createSync(recursive: true);
    }
    return p.join(dataDir.path, DatabaseConstants.dbName);
  }
}
