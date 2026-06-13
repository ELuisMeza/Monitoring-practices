import 'package:following_practices/back/entities/entity_database.dart';

/// Mapeo de la tabla `usuarios`.
class Usuario {
  const Usuario({
    this.id,
    required this.nombre,
    required this.email,
    required this.passwordHash,
    required this.rol,
    this.telefono,
    this.empresaId,
    this.createdAt,
  });

  static const tableName = 'usuarios';

  static const rolEstudiante = 'estudiante';
  static const rolTutor = 'tutor';
  static const rolSupervisor = 'supervisor';
  static const rolCoordinador = 'coordinador';

  final int? id;
  final String nombre;
  final String email;
  final String passwordHash;
  final String rol;
  final String? telefono;
  final int? empresaId;
  final String? createdAt;

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      rol: map['rol'] as String,
      telefono: map['telefono'] as String?,
      empresaId: map['empresa_id'] as int?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'email': email,
      'password_hash': passwordHash,
      'rol': rol,
      'telefono': telefono,
      'empresa_id': empresaId,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  Future<Usuario> create() async {
    final newId = await EntityDatabase.insert(tableName, mapForInsert(toMap()));
    return Usuario.fromMap({...toMap(), 'id': newId});
  }

  static Future<Usuario?> read(int id) async {
    final row = await EntityDatabase.findById(tableName, id);
    return row == null ? null : Usuario.fromMap(row);
  }

  static Future<List<Usuario>> readAll({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final rows = await EntityDatabase.findAll(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
    return rows.map(Usuario.fromMap).toList();
  }

  Future<int> update() async {
    if (id == null) {
      throw StateError('No se puede actualizar un usuario sin id.');
    }
    return EntityDatabase.updateById(tableName, mapForUpdate(toMap()), id!);
  }

  Future<int> delete() async {
    if (id == null) {
      throw StateError('No se puede eliminar un usuario sin id.');
    }
    return EntityDatabase.deleteById(tableName, id!);
  }

  static Future<List<Usuario>> readByRol(String rol) {
    return readAll(
      where: 'rol = ?',
      whereArgs: [rol],
      orderBy: 'nombre ASC',
    );
  }

  static Future<Usuario?> readByEmail(String email) async {
    final usuarios = await readAll(
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    return usuarios.isEmpty ? null : usuarios.first;
  }
}
