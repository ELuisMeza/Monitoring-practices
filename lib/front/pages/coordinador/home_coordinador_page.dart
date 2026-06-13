import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/dashboard_coordinador_dto.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/components/progress_card.dart';
import 'package:following_practices/front/services/auth_service.dart';
import 'package:following_practices/front/services/coordinador_service.dart';
import 'package:go_router/go_router.dart';

class HomeCoordinadorPage extends StatefulWidget {
  const HomeCoordinadorPage({super.key});

  @override
  State<HomeCoordinadorPage> createState() => _HomeCoordinadorPageState();
}

class _HomeCoordinadorPageState extends State<HomeCoordinadorPage> {
  final _coordinadorService = CoordinadorService();
  final _authService = AuthService();
  DashboardCoordinadorDto? _dashboard;
  bool _cargando = true;
  String? _estadoFiltro;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final dashboard = await _coordinadorService.obtenerDashboard();
    setState(() {
      _dashboard = dashboard;
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
        title: const Text('Coordinación de prácticas'),
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
                  const SizedBox(height: 16),
                  if (_dashboard != null) ...[
                    _MetricTile(
                      icon: Icons.work,
                      label: 'Prácticas activas',
                      value: '${_dashboard!.practicasActivas}',
                    ),
                    _MetricTile(
                      icon: Icons.people,
                      label: 'Estudiantes',
                      value: '${_dashboard!.totalEstudiantes}',
                    ),
                    _MetricTile(
                      icon: Icons.schedule,
                      label: 'Horas acumuladas',
                      value: '${_dashboard!.totalHorasAcumuladas.toStringAsFixed(1)} h',
                    ),
                    _MetricTile(
                      icon: Icons.pending_actions,
                      label: 'Pendientes de revisión',
                      value: '${_dashboard!.actividadesPendientes}',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      initialValue: _estadoFiltro,
                      decoration: const InputDecoration(labelText: 'Filtrar por estado'),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Todas')),
                        DropdownMenuItem(value: 'activa', child: Text('Activas')),
                        DropdownMenuItem(value: 'completada', child: Text('Completadas')),
                        DropdownMenuItem(value: 'suspendida', child: Text('Suspendidas')),
                      ],
                      onChanged: (v) => setState(() => _estadoFiltro = v),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.push('/coordinador/practicas'),
                      child: const Text('Ver todas las prácticas'),
                    ),
                    const SizedBox(height: 24),
                    Text('Administración',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => context.push('/coordinador/usuarios'),
                          icon: const Icon(Icons.people),
                          label: const Text('Usuarios'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/coordinador/empresas'),
                          icon: const Icon(Icons.business),
                          label: const Text('Empresas'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/coordinador/practicas-admin'),
                          icon: const Icon(Icons.work),
                          label: const Text('Prácticas'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Prácticas activas',
                        style: Theme.of(context).textTheme.titleMedium),
                    ..._dashboard!.practicas
                        .where((p) => _estadoFiltro == null || p.estado == _estadoFiltro)
                        .map(
                          (p) => Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.estudianteNombre,
                                      style: Theme.of(context).textTheme.titleSmall),
                                  Text(p.empresaNombre),
                                  const SizedBox(height: 8),
                                  ProgressCard(
                                    titulo: 'Avance',
                                    valor: p.horasAcumuladas,
                                    maximo: p.horasRequeridas.toDouble(),
                                    subtitulo: '${p.actividadesPendientes} pendiente(s)',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
