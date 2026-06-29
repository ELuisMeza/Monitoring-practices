import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/actividad_list_item_dto.dart';
import 'package:following_practices/front/components/actividad_card.dart';
import 'package:following_practices/front/components/action_tile.dart';
import 'package:following_practices/front/components/animated_fade_slide.dart';
import 'package:following_practices/front/components/app_page_header.dart';
import 'package:following_practices/front/components/empty_state.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/components/stat_card.dart';
import 'package:following_practices/front/lib/theme/app_colors.dart';
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

    final pendientes = await _actividadService.listarPendientesTutor(sesion.id);

    await _alertaService.evaluarRevisor(sesion.id, pendientes.length);

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

                          subtitle: 'Panel de tutor',

                          gradient: AppColors.secondaryGradient,

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
                              StatGrid(
                                children: [
                                  StatCard(
                                    icon: Icons.pending_actions_outlined,

                                    label: 'Pendientes',

                                    value: '${_pendientes.length}',

                                    color: AppColors.warning,
                                  ),

                                  StatCard(
                                    icon: Icons.rate_review_outlined,

                                    label: 'Por revisar',

                                    value: '${_pendientes.length}',

                                    color: AppColors.secondary,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              ActionTile(
                                icon: Icons.rate_review_rounded,

                                label: 'Revisar actividades',

                                filled: true,

                                color: AppColors.secondary,

                                onTap: () => context.push('/tutor/revision'),
                              ),

                              const SizedBox(height: 24),

                              Text(
                                'Actividades recientes',

                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),

                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_pendientes.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,

                      child: EmptyState(
                        icon: Icons.check_circle_outline,

                        mensaje: 'No hay actividades pendientes de revisión.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),

                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final actividad = _pendientes[index];
                          return AnimatedFadeSlide(
                            delay: Duration(milliseconds: 80 * index),

                            child: ActividadCard(
                              actividad: actividad,

                              onTap: () =>
                                  context.push('/revision/${actividad.id}'),
                            ),
                          );
                        }, childCount: _pendientes.length.clamp(0, 5)),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
