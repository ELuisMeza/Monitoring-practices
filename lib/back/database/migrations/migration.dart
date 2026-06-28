import 'package:sqflite_common/sqlite_api.dart';

/// Contrato para una migración versionada de la base de datos.
abstract class Migration {
  int get version;

  String get name;

  Future<void> up(
    DatabaseExecutor db,
  );
}