import 'package:following_practices/back/database/migrations/migration.dart';
import 'package:following_practices/back/utils/password_hash.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Migración 004: garantiza usuarios demo aunque ya existan otros registros.
///
/// La migración 003 omitía el seed si había cualquier usuario (p. ej. creado
/// desde la pantalla CRUD de desarrollo con contraseña en texto plano).
class Migration004EnsureDemoUsers extends Migration {
  @override
  int get version => 4;

  @override
  String get name => 'ensure_demo_users';

  static const _demoPassword = '123456';

  static const _demoUsers = [
    ('Ana Estudiante', 'estudiante@demo.com', 'estudiante'),
    ('Carlos Tutor', 'tutor@demo.com', 'tutor'),
    ('María Supervisor', 'supervisor@demo.com', 'supervisor'),
    ('Luis Coordinador', 'coord@demo.com', 'coordinador'),
  ];

  @override
  Future<void> up(DatabaseExecutor db) async {
    final hash = PasswordHash.hash(_demoPassword);

    for (final (nombre, email, rol) in _demoUsers) {
      await _upsertUsuario(db, nombre: nombre, email: email, rol: rol, hash: hash);
    }

    final estudianteId = await _idByEmail(db, 'estudiante@demo.com');
    final tutorId = await _idByEmail(db, 'tutor@demo.com');
    final supervisorId = await _idByEmail(db, 'supervisor@demo.com');
    if (estudianteId == null || tutorId == null || supervisorId == null) return;

    final empresaId = await _ensureEmpresa(db);
    await _ensurePracticaActiva(
      db,
      estudianteId: estudianteId,
      empresaId: empresaId,
      tutorId: tutorId,
      supervisorId: supervisorId,
    );
  }

  Future<void> _upsertUsuario(
    DatabaseExecutor db, {
    required String nombre,
    required String email,
    required String rol,
    required String hash,
  }) async {
    final existing = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (existing.isEmpty) {
      await db.insert('usuarios', {
        'nombre': nombre,
        'email': email,
        'password_hash': hash,
        'rol': rol,
      });
    } else {
      await db.update(
        'usuarios',
        {
          'nombre': nombre,
          'password_hash': hash,
          'rol': rol,
        },
        where: 'email = ?',
        whereArgs: [email],
      );
    }
  }

  Future<int?> _idByEmail(DatabaseExecutor db, String email) async {
    final rows = await db.query(
      'usuarios',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['id'] as int;
  }

  Future<int> _ensureEmpresa(DatabaseExecutor db) async {
    const qrToken = 'DEMO-QR-TECH-001';
    final existing = await db.query(
      'empresas',
      where: 'qr_token = ?',
      whereArgs: [qrToken],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }

    return db.insert('empresas', {
      'nombre': 'Tech Solutions SAC',
      'ruc': '20123456789',
      'direccion': 'Av. Principal 123',
      'contacto_nombre': 'María Supervisor',
      'contacto_email': 'supervisor@demo.com',
      'qr_token': qrToken,
    });
  }

  Future<void> _ensurePracticaActiva(
    DatabaseExecutor db, {
    required int estudianteId,
    required int empresaId,
    required int tutorId,
    required int supervisorId,
  }) async {
    final existing = await db.query(
      'practicas',
      where: 'estudiante_id = ? AND estado = ?',
      whereArgs: [estudianteId, 'activa'],
      limit: 1,
    );

    if (existing.isNotEmpty) return;

    await db.insert('practicas', {
      'estudiante_id': estudianteId,
      'empresa_id': empresaId,
      'tutor_id': tutorId,
      'supervisor_id': supervisorId,
      'fecha_inicio': '2026-01-01',
      'fecha_fin': '2026-06-30',
      'horas_requeridas': 240,
      'estado': 'activa',
    });
  }
}
