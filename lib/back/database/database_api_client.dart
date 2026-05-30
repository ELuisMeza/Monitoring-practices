import 'dart:io';

import 'package:following_practices/back/database/database_constants.dart';
import 'package:following_practices/back/database/migrations/migration_runner.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Punto único de acceso a la base de datos SQLite.
///
/// Toda comunicación con la BD debe pasar por esta clase.
class DatabaseApiClient {
  DatabaseApiClient();

  Database? _database;

  /// Instancia activa de la base de datos. Lanza si no se ha inicializado.
  Database get database {
    final db = _database;
    if (db == null || !db.isOpen) {
      throw StateError(
        'DatabaseApiClient no está inicializado. Llame a initialize() primero.',
      );
    }
    return db;
  }

  bool get isInitialized => _database != null && _database!.isOpen;

  /// Abre la base de datos y ejecuta migraciones pendientes.
  Future<void> initialize({String? databasePath}) async {
    if (isInitialized) return;

    final path = databasePath ?? await _resolveDefaultPath();
    _database = await openDatabase(
      path,
      version: DatabaseConstants.dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );

    await runMigrations();
  }

  /// Ejecuta todas las migraciones pendientes.
  Future<List<int>> runMigrations() async {
    return MigrationRunner.run(database);
  }

  /// Cierra la conexión activa.
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
    _database = null;
  }

  /// Ejecuta [action] dentro de una transacción atómica.
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) {
    return database.transaction(action);
  }

  Future<String> _resolveDefaultPath() async {
    if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return p.join(dir.path, DatabaseConstants.dbName);
    }

    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, DatabaseConstants.dbName);
  }
}
