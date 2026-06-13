/// Métricas globales para el coordinador.
class DashboardCoordinadorDto {
  const DashboardCoordinadorDto({
    required this.practicasActivas,
    required this.totalEstudiantes,
    required this.totalHorasAcumuladas,
    required this.actividadesPendientes,
    required this.practicas,
  });

  final int practicasActivas;
  final int totalEstudiantes;
  final double totalHorasAcumuladas;
  final int actividadesPendientes;
  final List<PracticaDashboardItemDto> practicas;
}

class PracticaDashboardItemDto {
  const PracticaDashboardItemDto({
    required this.practicaId,
    required this.estudianteNombre,
    required this.empresaNombre,
    required this.horasAcumuladas,
    required this.horasRequeridas,
    required this.estado,
    required this.actividadesPendientes,
  });

  final int practicaId;
  final String estudianteNombre;
  final String empresaNombre;
  final double horasAcumuladas;
  final int horasRequeridas;
  final String estado;
  final int actividadesPendientes;
}
