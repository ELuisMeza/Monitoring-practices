import 'package:following_practices/back/database/database_constants.dart';
import 'package:following_practices/back/database/database_path.dart';
import 'package:sqflite/sqflite.dart';

/// Punto único de acceso a la base de datos SQLite.
///
/// Solo abre la conexión. Las migraciones se ejecutan únicamente con
/// `dart run bin/migrate.dart`.
class DatabaseApiClient {
  DatabaseApiClient();

  Database? _database;

  /// Instancia activa de la base de datos. Lanza si no se ha inicializado.
  Database get database {
    final db = _database;

    if (db == null || !db.isOpen) {
      throw StateError(
        'DatabaseApiClient no está inicializado. '
        'Llame a initialize() primero.',
      );
    }

    return db;
  }

  bool get isInitialized => _database != null && _database!.isOpen;

  /// Abre la BD del entorno (`data/following_practices.db`).
  /// Sin migraciones.
  Future<void> initialize({
    String? databasePath,
  }) async {
    if (isInitialized) {
      return;
    }

    final path = databasePath ?? await DatabasePath.resolve();

    _database = await openDatabase(
      path,
      version: DatabaseConstants.dbVersion,
      onConfigure: (db) async {
        await db.execute(
          'PRAGMA foreign_keys = ON',
        );
      },
    );
  }

  /// Cierra la conexión activa.
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }

    _database = null;
  }

  /// Ejecuta [action] dentro de una transacción atómica.
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action,
  ) {
    return database.transaction(action);
  }
}