import 'package:following_practices/back/entities/entity_database.dart';

/// Mapeo de la tabla `empresas`.
class Empresa {
  const Empresa({
    this.id,
    required this.nombre,
    this.ruc,
    this.direccion,
    this.contactoNombre,
    this.contactoEmail,
    required this.qrToken,
    this.createdAt,
  });

  static const tableName = 'empresas';

  final int? id;
  final String nombre;
  final String? ruc;
  final String? direccion;
  final String? contactoNombre;
  final String? contactoEmail;
  final String qrToken;
  final String? createdAt;

  factory Empresa.fromMap(Map<String, dynamic> map) {
    return Empresa(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      ruc: map['ruc'] as String?,
      direccion: map['direccion'] as String?,
      contactoNombre: map['contacto_nombre'] as String?,
      contactoEmail: map['contacto_email'] as String?,
      qrToken: map['qr_token'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'ruc': ruc,
      'direccion': direccion,
      'contacto_nombre': contactoNombre,
      'contacto_email': contactoEmail,
      'qr_token': qrToken,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  Future<Empresa> create() async {
    final newId = await EntityDatabase.insert(tableName, mapForInsert(toMap()));
    return Empresa.fromMap({...toMap(), 'id': newId});
  }

  static Future<Empresa?> read(int id) async {
    final row = await EntityDatabase.findById(tableName, id);
    return row == null ? null : Empresa.fromMap(row);
  }

  static Future<List<Empresa>> readAll({
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
    return rows.map(Empresa.fromMap).toList();
  }

  Future<int> update() async {
    if (id == null) {
      throw StateError('No se puede actualizar una empresa sin id.');
    }
    return EntityDatabase.updateById(tableName, mapForUpdate(toMap()), id!);
  }

  Future<int> delete() async {
    if (id == null) {
      throw StateError('No se puede eliminar una empresa sin id.');
    }
    return EntityDatabase.deleteById(tableName, id!);
  }

  static Future<Empresa?> readByQrToken(String qrToken) async {
    final empresas = await readAll(
      where: 'qr_token = ?',
      whereArgs: [qrToken.trim()],
      limit: 1,
    );
    return empresas.isEmpty ? null : empresas.first;
  }
}
