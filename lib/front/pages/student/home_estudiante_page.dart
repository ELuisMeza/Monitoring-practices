import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/practica_resumen_dto.dart';
import 'package:following_practices/back/dtos/resumen_horas_semanal_dto.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/components/progress_card.dart';
import 'package:following_practices/front/services/actividad_service.dart';
import 'package:following_practices/front/services/alerta_service.dart';
import 'package:following_practices/front/services/auth_service.dart';
import 'package:following_practices/front/services/practica_service.dart';
import 'package:go_router/go_router.dart';

class HomeEstudiantePage extends StatefulWidget {
  const HomeEstudiantePage({super.key});

  @override
  State<HomeEstudiantePage> createState() => _HomeEstudiantePageState();
}

class _HomeEstudiantePageState extends State<HomeEstudiantePage> {
  final _actividadService = ActividadService();
  final _practicaService = PracticaService();
  final _alertaService = AlertaService();
  final _authService = AuthService();

  ResumenHorasSemanalDto? _resumen;
  PracticaResumenDto? _practica;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final sesion = _authService.sesionActual;
    if (sesion == null) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resumen = await _actividadService.obtenerHorasUltimaSemana(sesion.id);
      final practica = await _practicaService.obtenerPracticaActiva(sesion.id);
      await _alertaService.evaluarEstudiante(sesion.id);

      setState(() {
        _resumen = resumen;
        _practica = practica;
        _error = practica == null ? 'Sin práctica activa.' : null;
        _cargando = false;
      });
    } catch (_) {
      setState(() {
        _error = 'No se pudo cargar el resumen.';
        _cargando = false;
      });
    }
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
        title: const Text('Mi práctica'),
        actions: [
          IconButton(
            tooltip: 'Alertas',
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/alertas'),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _cargando
          ? const LoadingView()
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Hola, ${sesion?.nombre ?? ''}',
                          style: Theme.of(context).textTheme.titleLarge),
                      if (_practica != null) ...[
                        const SizedBox(height: 8),
                        Text(_practica!.empresaNombre),
                      ],
                      const SizedBox(height: 16),
                      if (_practica != null)
                        ProgressCard(
                          titulo: 'Horas acumuladas',
                          valor: _practica!.horasAcumuladas,
                          maximo: _practica!.horasRequeridas.toDouble(),
                        ),
                      const SizedBox(height: 16),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Horas última semana'),
                          subtitle: Text(
                            _resumen != null
                                ? '${_resumen!.totalHoras} h · ${_resumen!.cantidadActividades} actividades'
                                : '—',
                          ),
                          trailing: TextButton(
                            onPressed: () => context.push('/estudiante/reporte'),
                            child: const Text('Ver reporte'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            onPressed: () => context.push('/estudiante/actividad/nueva'),
                            icon: const Icon(Icons.add),
                            label: const Text('Registrar actividad'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/estudiante/actividades'),
                            icon: const Icon(Icons.list),
                            label: const Text('Historial'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/estudiante/qr'),
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Asistencia QR'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/estudiante/perfil'),
                            icon: const Icon(Icons.person),
                            label: const Text('Mi práctica'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
