import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:following_practices/back/database/database_path_core.dart';

/// Sincroniza la BD del emulador (debug) desde la copia enviada con `adb push`.
class DatabaseSync {
  DatabaseSync._();

  /// Copia `/data/local/tmp/following_practices.db` → ruta writable de la app.
  static Future<void> importFromTmpIfNeeded(String targetPath) async {
    if (!Platform.isAndroid || !kDebugMode) return;

    final tmpFile = File(DatabasePathCore.debugAndroidSharedPath);
    if (!await tmpFile.exists()) return;

    final target = File(targetPath);
    await target.parent.create(recursive: true);
    await tmpFile.copy(target.path);
  }
}
