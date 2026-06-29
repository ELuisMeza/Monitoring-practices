import 'package:flutter/material.dart';
import 'package:following_practices/front/components/action_tile.dart';
import 'package:following_practices/front/components/animated_fade_slide.dart';
import 'package:following_practices/front/components/app_page_header.dart';
import 'package:following_practices/front/components/empty_state.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/components/progress_card.dart';
import 'package:following_practices/front/lib/theme/app_colors.dart';
import 'package:following_practices/front/services/actividad_service.dart';
import 'package:following_practices/front/services/alerta_service.dart';
import 'package:following_practices/front/services/auth_service.dart';
import 'package:following_practices/front/services/practica_service.dart';
import 'package:following_practices/back/dtos/practica_resumen_dto.dart';
import 'package:following_practices/back/dtos/resumen_horas_semanal_dto.dart';
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
      body: _cargando
          ? const LoadingView(mensaje: 'Cargando tu práctica...')
          : _error != null
              ? Center(
                  child: EmptyState(
                    icon: Icons.work_off_outlined,
                    mensaje: _error!,
                    accion: FilledButton(
                      onPressed: _cargar,
                      child: const Text('Reintentar'),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  color: AppColors.primary,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppPageHeader(
                              title: 'Hola, ${sesion?.nombre ?? ''}',
                              subtitle: _practica?.empresaNombre ?? 'Mi práctica',
                              trailing: AppHeaderActions(
                                actions: [
                                  IconButton(
                                    icon: const Icon(Icons.notifications_outlined),
                                    onPressed: () => context.push('/alertas'),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.logout),
                                    onPressed: _logout,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                              child: StaggeredList(
                                children: [
                                  if (_practica != null)
                                    ProgressCard(
                                      titulo: 'Horas acumuladas',
                                      valor: _practica!.horasAcumuladas,
                                      maximo: _practica!.horasRequeridas.toDouble(),
                                      color: AppColors.secondary,
                                    ),
                                  const SizedBox(height: 12),
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: AppColors.accent.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.calendar_today_outlined,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Horas última semana',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(fontWeight: FontWeight.w700),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  _resumen != null
                                                      ? '${_resumen!.totalHoras} h · ${_resumen!.cantidadActividades} actividades'
                                                      : '—',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: AppColors.textSecondary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                context.push('/estudiante/reporte'),
                                            child: const Text('Ver reporte'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Acciones rápidas',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      ActionTile(
                                        icon: Icons.add_rounded,
                                        label: 'Registrar actividad',
                                        filled: true,
                                        onTap: () =>
                                            context.push('/estudiante/actividad/nueva'),
                                      ),
                                      ActionTile(
                                        icon: Icons.list_alt_outlined,
                                        label: 'Historial',
                                        onTap: () =>
                                            context.push('/estudiante/actividades'),
                                      ),
                                      ActionTile(
                                        icon: Icons.qr_code_scanner_rounded,
                                        label: 'Asistencia QR',
                                        color: AppColors.secondary,
                                        onTap: () => context.push('/estudiante/qr'),
                                      ),
                                      ActionTile(
                                        icon: Icons.person_outline,
                                        label: 'Mi práctica',
                                        color: AppColors.accent,
                                        onTap: () => context.push('/estudiante/perfil'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
