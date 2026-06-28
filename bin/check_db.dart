import 'dart:io';

import 'package:following_practices/back/database/database_path_cli.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final path = DatabasePathCli.resolve();
  final db = await openDatabase(path);

  final users = await db.query(
    'usuarios',
    columns: [
      'id',
      'email',
      'rol',
      'password_hash',
    ],
  );

  print('Usuarios en $path:');

  for (final u in users) {
    print(
      '  ${u['id']} | '
      '${u['email']} | '
      '${u['rol']} | '
      'hash=${u['password_hash']}',
    );
  }

  if (users.isEmpty) {
    print('  (vacío — seed no aplicado)');
  }

  final migrations = await db.query(
    'schema_migrations',
    orderBy: 'version',
  );

  print(
    'Migraciones: ${migrations.map((m) => m['version']).toList()}',
  );

  await db.close();
}