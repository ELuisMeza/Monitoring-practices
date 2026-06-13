/// Usuario para listados de administración.
class UsuarioListItemDto {
  const UsuarioListItemDto({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.telefono,
    this.empresaId,
    this.empresaNombre,
  });

  final int id;
  final String nombre;
  final String email;
  final String rol;
  final String? telefono;
  final int? empresaId;
  final String? empresaNombre;
}
