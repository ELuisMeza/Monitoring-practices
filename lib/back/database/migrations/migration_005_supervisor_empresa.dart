import 'package:following_practices/back/database/migrations/migration.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Migración 005: supervisor pertenece a una empresa (`usuarios.empresa_id`).
class Migration005SupervisorEmpresa extends Migration {
  @override
  int get version => 5;

  @override
  String get name => 'supervisor_empresa';

  @override
  Future<void> up(DatabaseExecutor db) async {
    await db.execute('ALTER TABLE usuarios ADD COLUMN empresa_id INTEGER REFERENCES empresas(id)');

    // Backfill: supervisor demo → empresa demo por QR token.
    final empresaRows = await db.query(
      'empresas',
      where: 'qr_token = ?',
      whereArgs: ['DEMO-QR-TECH-001'],
      limit: 1,
    );
    if (empresaRows.isNotEmpty) {
      final empresaId = empresaRows.first['id'] as int;
      await db.update(
        'usuarios',
        {'empresa_id': empresaId},
        where: 'email = ?',
        whereArgs: ['supervisor@demo.com'],
      );
    }

    // Backfill: otros supervisores desde su primera práctica asignada.
    final supervisores = await db.query(
      'usuarios',
      where: 'rol = ? AND empresa_id IS NULL',
      whereArgs: ['supervisor'],
    );

    for (final sup in supervisores) {
      final supId = sup['id'] as int;
      final practica = await db.query(
        'practicas',
        where: 'supervisor_id = ?',
        whereArgs: [supId],
        orderBy: 'id ASC',
        limit: 1,
      );
      if (practica.isNotEmpty) {
        await db.update(
          'usuarios',
          {'empresa_id': practica.first['empresa_id']},
          where: 'id = ?',
          whereArgs: [supId],
        );
      }
    }
  }
}
