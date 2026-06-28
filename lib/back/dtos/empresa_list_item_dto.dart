/// Empresa para listados de administración.
class EmpresaListItemDto {
  const EmpresaListItemDto({
    required this.id,
    required this.nombre,
    this.ruc,
    this.direccion,
    required this.qrToken,
    required this.practicasActivas,
  });

  final int id;

  final String nombre;

  final String? ruc;

  final String? direccion;

  final String qrToken;

  final int practicasActivas;
}