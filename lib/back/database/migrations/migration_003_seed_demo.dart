import 'package:following_practices/back/database/migrations/migration.dart';
import 'package:following_practices/back/utils/password_hash.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Migración 003: datos demo para pruebas del MVP.
class Migration003SeedDemo extends Migration {
  @override
  int get version => 3;

  @override
  String get name => 'seed_demo';

  @override
  Future<void> up(
    DatabaseExecutor db,
  ) async {
    final rows = await db.query(
      'usuarios',
      limit: 1,
    );

    if (rows.isNotEmpty) {
      return;
    }

    final hash = PasswordHash.hash('123456');

    await db.insert(
      'usuarios',
      {
        'nombre': 'Ana Estudiante',
        'email': 'estudiante@demo.com',
        'password_hash': hash,
        'rol': 'estudiante',
      },
    );

    await db.insert(
      'usuarios',
      {
        'nombre': 'Carlos Tutor',
        'email': 'tutor@demo.com',
        'password_hash': hash,
        'rol': 'tutor',
      },
    );

    await db.insert(
      'usuarios',
      {
        'nombre': 'María Supervisor',
        'email': 'supervisor@demo.com',
        'password_hash': hash,
        'rol': 'supervisor',
      },
    );

    await db.insert(
      'usuarios',
      {
        'nombre': 'Luis Coordinador',
        'email': 'coord@demo.com',
        'password_hash': hash,
        'rol': 'coordinador',
      },
    );

    await db.insert(
      'empresas',
      {
        'nombre': 'Tech Solutions SAC',
        'ruc': '20123456789',
        'direccion': 'Av. Principal 123',
        'contacto_nombre': 'María Supervisor',
        'contacto_email': 'supervisor@demo.com',
        'qr_token': 'DEMO-QR-TECH-001',
      },
    );

    await db.insert(
      'practicas',
      {
        'estudiante_id': 1,
        'empresa_id': 1,
        'tutor_id': 2,
        'supervisor_id': 3,
        'fecha_inicio': '2026-01-01',
        'fecha_fin': '2026-06-30',
        'horas_requeridas': 240,
        'estado': 'activa',
      },
    );
  }
}