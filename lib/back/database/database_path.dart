import 'dart:io';

import 'package:following_practices/back/database/database_constants.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Ruta de la BD para la app Flutter (emulador, móvil, desktop).
///
/// Regla única: `{directorio_app}/data/following_practices.db`
class DatabasePath {
  DatabasePath._();

  static Future<String> resolve({String? override}) async {
    if (override != null && override.isNotEmpty) return override;

    final base = await _baseDirectory();
    return _buildPath(base);
  }

  static Future<Directory> _baseDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return getApplicationDocumentsDirectory();
    }
    return getApplicationSupportDirectory();
  }

  static String _buildPath(Directory base) {
    final dataDir = Directory(
      p.join(base.path, DatabaseConstants.storageDir),
    );
    if (!dataDir.existsSync()) {
      dataDir.createSync(recursive: true);
    }
    return p.join(dataDir.path, DatabaseConstants.dbName);
  }
}
