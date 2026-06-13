/// Alerta de avance para un usuario.
class AlertaDto {
  const AlertaDto({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.leida,
    required this.createdAt,
  });

  final int id;
  final int usuarioId;
  final String tipo;
  final String titulo;
  final String mensaje;
  final bool leida;
  final String createdAt;
}
