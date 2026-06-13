import 'package:following_practices/back/dtos/usuario_sesion_dto.dart';
import 'package:following_practices/front/lib/service_locator.dart';
import 'package:following_practices/front/lib/session/session_service.dart';

/// Puerta de entrada del front para autenticación.
class AuthService {
  AuthService({
    SessionService? sessionService,
  }) : _sessionService = sessionService ?? SessionService();

  final SessionService _sessionService;

  UsuarioSesionDto? get sesionActual => ServiceLocator.auth.sesionActual;

  Future<UsuarioSesionDto> login(String email, String password) async {
    final sesion = await ServiceLocator.auth.login(email, password);
    await _sessionService.guardar(sesion);
    return sesion;
  }

  Future<UsuarioSesionDto?> restaurarSesion() async {
    final sesion = await _sessionService.cargar();
    if (sesion != null) {
      ServiceLocator.auth.restaurarSesion(sesion);
    }
    return sesion;
  }

  Future<void> logout() async {
    ServiceLocator.auth.logout();
    await _sessionService.limpiar();
  }
}
