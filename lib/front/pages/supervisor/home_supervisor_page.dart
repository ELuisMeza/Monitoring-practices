import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/asistencia_dto.dart';
import 'package:following_practices/back/dtos/supervisor_alcance_dto.dart';
import 'package:following_practices/front/components/action_tile.dart';
import 'package:following_practices/front/components/animated_fade_slide.dart';
import 'package:following_practices/front/components/app_page_header.dart';
import 'package:following_practices/front/components/empty_state.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/components/stat_card.dart';
import 'package:following_practices/front/lib/theme/app_colors.dart';
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
      body: _cargando
          ? const LoadingView(mensaje: 'Cargando panel...')
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
                          subtitle: _alcance?.empresaNombre ?? 'Panel supervisor',
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.accent,
                              AppColors.accentLight,
                            ],
                          ),
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
                              if (_alcance != null)
                                StatGrid(
                                  children: [
                                    StatCard(
                                      icon: Icons.people_outline,
                                      label: 'Practicantes activos',
                                      value: '${_alcance!.practicantesActivos}',
                                      color: AppColors.accent,
                                    ),
                                    StatCard(
                                      icon: Icons.access_time,
                                      label: 'Asistencias hoy',
                                      value: '${_asistencias.length}',
                                      color: AppColors.secondary,
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 20),
                              ActionTile(
                                icon: Icons.fact_check_outlined,
                                label: 'Validar actividades',
                                filled: true,
                                color: AppColors.accent,
                                onTap: () => context.push('/supervisor/validacion'),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Asistencias de hoy',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_asistencias.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.access_time,
                        mensaje: 'Sin asistencias registradas hoy.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final a = _asistencias[index];
                            final isEntrada = a.tipo == 'entrada';
                            return AnimatedFadeSlide(
                              delay: Duration(milliseconds: 60 * index),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Card(
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: (isEntrada
                                                ? AppColors.success
                                                : AppColors.warning)
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        isEntrada
                                            ? Icons.login_rounded
                                            : Icons.logout_rounded,
                                        color: isEntrada
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ),
                                    title: Text(
                                      a.estudianteNombre ?? 'Estudiante',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(a.tipo.toUpperCase()),
                                    trailing: Text(
                                      a.hora,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: _asistencias.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
