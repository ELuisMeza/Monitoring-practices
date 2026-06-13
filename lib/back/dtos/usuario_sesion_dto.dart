/// Sesión de usuario autenticado.
class UsuarioSesionDto {
  const UsuarioSesionDto({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
  });

  final int id;
  final String nombre;
  final String email;
  final String rol;
}
