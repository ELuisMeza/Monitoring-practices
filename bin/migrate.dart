import 'dart:io';

import 'package:following_practices/back/database/database_constants.dart';
import 'package:following_practices/back/database/database_path_cli.dart';
import 'package:following_practices/back/database/migrations/migration_runner.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Único punto para crear/actualizar el esquema de la base de datos.
///
/// Las migraciones NO se ejecutan al iniciar la app; solo con este script.
///
/// Uso:
///   dart run bin/migrate.dart
///   dart run bin/migrate.dart --path ./data/following_practices.db
Future<void> main(List<String> args) async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final customPath = _readPathArg(args);
  final dbPath = DatabasePathCli.resolve(override: customPath);

  stdout.writeln('Ejecutando migraciones en: $dbPath');

  final db = await openDatabase(
    dbPath,
    version: DatabaseConstants.dbVersion,
    onConfigure: (database) async {
      await database.execute('PRAGMA foreign_keys = ON');
    },
  );

  final applied = await MigrationRunner.run(db);

  if (applied.isEmpty) {
    stdout.writeln('No hay migraciones pendientes. Esquema al día.');
  } else {
    stdout.writeln('Migraciones aplicadas: ${applied.join(', ')}');
  }

  await db.close();
  stdout.writeln('Migración completada.');
}

String? _readPathArg(List<String> args) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--path' && i + 1 < args.length) {
      return args[i + 1];
    }
  }
  return null;
}
