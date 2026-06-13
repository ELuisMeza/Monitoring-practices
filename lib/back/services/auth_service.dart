import 'package:following_practices/back/dtos/usuario_sesion_dto.dart';
import 'package:following_practices/back/entities/usuario.dart';
import 'package:following_practices/back/utils/password_hash.dart';
import 'package:following_practices/back/validators/input_validator.dart';

/// Autenticación local por email y contraseña.
class AuthService {
  UsuarioSesionDto? _sesionActual;

  UsuarioSesionDto? get sesionActual => _sesionActual;

  Future<UsuarioSesionDto> login(String email, String password) async {
    final emailError = InputValidator.email(email);
    if (emailError != null) throw ArgumentError(emailError);

    final passError = InputValidator.password(password);
    if (passError != null) throw ArgumentError(passError);

    final usuario = await Usuario.readByEmail(email.trim().toLowerCase());
    if (usuario == null || !PasswordHash.verify(password, usuario.passwordHash)) {
      throw StateError('Credenciales inválidas.');
    }

    _sesionActual = UsuarioSesionDto(
      id: usuario.id!,
      nombre: usuario.nombre,
      email: usuario.email,
      rol: usuario.rol,
    );
    return _sesionActual!;
  }

  void restaurarSesion(UsuarioSesionDto sesion) {
    _sesionActual = sesion;
  }

  void logout() {
    _sesionActual = null;
  }
}
