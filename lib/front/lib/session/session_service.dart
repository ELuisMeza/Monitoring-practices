import 'dart:convert';

import 'package:following_practices/back/dtos/usuario_sesion_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistencia de sesión local.
class SessionService {
  static const _keySesion = 'usuario_sesion';

  Future<void> guardar(UsuarioSesionDto sesion) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySesion, jsonEncode({
      'id': sesion.id,
      'nombre': sesion.nombre,
      'email': sesion.email,
      'rol': sesion.rol,
    }));
  }

  Future<UsuarioSesionDto?> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySesion);
    if (raw == null) return null;

    final map = jsonDecode(raw) as Map<String, dynamic>;
    return UsuarioSesionDto(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      email: map['email'] as String,
      rol: map['rol'] as String,
    );
  }

  Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySesion);
  }
}
