import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/asistencia_dto.dart';
import 'package:following_practices/back/dtos/supervisor_alcance_dto.dart';
import 'package:following_practices/front/components/empty_state.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/services/asistencia_service.dart';
import 'package:following_practices/front/services/auth_service.dart';
import 'package:following_practices/front/services/practica_service.dart';
import 'package:go_router/go_router.dart';

class HomeSupervisorPage extends StatefulWidget {
  const HomeSupervisorPage({super.key});

  @override
  State<HomeSupervisorPage> createState() => _HomeSupervisorPageState();
}

class _HomeSupervisorPageState extends State<HomeSupervisorPage> {
  final _asistenciaService = AsistenciaService();
  final _practicaService = PracticaService();
  final _authService = AuthService();
  List<AsistenciaDto> _asistencias = [];
  SupervisorAlcanceDto? _alcance;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final sesion = _authService.sesionActual;
    if (sesion == null) return;
    final asistencias = await _asistenciaService.listarHoySupervisor(sesion.id);
    final alcance = await _practicaService.obtenerAlcanceSupervisor(sesion.id);
    setState(() {
      _asistencias = asistencias;
      _alcance = alcance;
      _cargando = false;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final sesion = _authService.sesionActual;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel supervisor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/alertas'),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _cargando
          ? const LoadingView()
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Hola, ${sesion?.nombre ?? ''}',
                      style: Theme.of(context).textTheme.titleLarge),
                  if (_alcance?.empresaNombre != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Empresa: ${_alcance!.empresaNombre}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      '${_alcance!.practicantesActivos} practicante(s) activo(s)',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.push('/supervisor/validacion'),
                    icon: const Icon(Icons.fact_check),
                    label: const Text('Validar actividades'),
                  ),
                  const SizedBox(height: 24),
                  Text('Asistencias de hoy',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (_asistencias.isEmpty)
                    const EmptyState(
                      icon: Icons.access_time,
                      mensaje: 'Sin asistencias registradas hoy.',
                    )
                  else
                    ..._asistencias.map(
                      (a) => ListTile(
                        leading: Icon(
                          a.tipo == 'entrada' ? Icons.login : Icons.logout,
                        ),
                        title: Text(a.estudianteNombre ?? 'Estudiante'),
                        subtitle: Text(a.tipo.toUpperCase()),
                        trailing: Text(a.hora),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
