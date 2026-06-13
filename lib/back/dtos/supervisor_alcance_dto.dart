/// Alcance operativo del supervisor (empresa asignada y practicantes).
class SupervisorAlcanceDto {
  const SupervisorAlcanceDto({
    this.empresaNombre,
    required this.practicantesActivos,
  });

  final String? empresaNombre;
  final int practicantesActivos;
}
