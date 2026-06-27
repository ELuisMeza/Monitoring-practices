import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/actividad_list_item_dto.dart';
import 'package:following_practices/front/components/actividad_card.dart';
import 'package:following_practices/front/components/empty_state.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/services/actividad_service.dart';
import 'package:following_practices/front/services/alerta_service.dart';
import 'package:following_practices/front/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class HomeTutorPage extends StatefulWidget {
  const HomeTutorPage({super.key});

  @override
  State<HomeTutorPage> createState() => _HomeTutorPageState();
}

class _HomeTutorPageState extends State<HomeTutorPage> {
  final _actividadService = ActividadService();
  final _alertaService = AlertaService();
  final _authService = AuthService();

  List<ActividadListItemDto> _pendientes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final sesion = _authService.sesionActual;

    if (sesion == null) return;

    final pendientes = await _actividadService.listarPendientesTutor(
      sesion.id,
    );

    await _alertaService.evaluarRevisor(
      sesion.id,
      pendientes.length,
    );

    setState(() {
      _pendientes = pendientes;
      _cargando = false;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sesion = _authService.sesionActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel tutor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/alertas'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _cargando
          ? const LoadingView()
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Hola, ${sesion?.nombre ?? ''}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_pendientes.length} actividad(es) pendiente(s)',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.push('/tutor/revision'),
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Revisar actividades'),
                  ),
                  const SizedBox(height: 24),
                  if (_pendientes.isEmpty)
                    const EmptyState(
                      icon: Icons.check_circle,
                      mensaje:
                          'No hay actividades pendientes de revisión.',
                    )
                  else
                    ..._pendientes.take(5).map(
                          (actividad) => ActividadCard(
                            actividad: actividad,
                            onTap: () => context.push(
                              '/revision/${actividad.id}',
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}