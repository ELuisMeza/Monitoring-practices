import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/dashboard_coordinador_dto.dart';
import 'package:following_practices/front/components/action_tile.dart';
import 'package:following_practices/front/components/animated_fade_slide.dart';
import 'package:following_practices/front/components/app_page_header.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/components/progress_card.dart';
import 'package:following_practices/front/components/stat_card.dart';
import 'package:following_practices/front/lib/theme/app_colors.dart';
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
      body: _cargando
          ? const LoadingView(mensaje: 'Cargando dashboard...')
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
                          subtitle: 'Coordinación de prácticas',
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
                        if (_dashboard != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                            child: StaggeredList(
                              children: [
                                StatGrid(
                                  children: [
                                    StatCard(
                                      icon: Icons.work_outline,
                                      label: 'Prácticas activas',
                                      value: '${_dashboard!.practicasActivas}',
                                      color: AppColors.primary,
                                    ),
                                    StatCard(
                                      icon: Icons.people_outline,
                                      label: 'Estudiantes',
                                      value: '${_dashboard!.totalEstudiantes}',
                                      color: AppColors.secondary,
                                    ),
                                    StatCard(
                                      icon: Icons.schedule_outlined,
                                      label: 'Horas acumuladas',
                                      value:
                                          '${_dashboard!.totalHorasAcumuladas.toStringAsFixed(1)} h',
                                      color: AppColors.accent,
                                    ),
                                    StatCard(
                                      icon: Icons.pending_actions_outlined,
                                      label: 'Pendientes',
                                      value: '${_dashboard!.actividadesPendientes}',
                                      color: AppColors.warning,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                DropdownButtonFormField<String?>(
                                  initialValue: _estadoFiltro,
                                  decoration: const InputDecoration(
                                    labelText: 'Filtrar por estado',
                                    prefixIcon: Icon(Icons.filter_list),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: null,
                                      child: Text('Todas'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'activa',
                                      child: Text('Activas'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'completada',
                                      child: Text('Completadas'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'suspendida',
                                      child: Text('Suspendidas'),
                                    ),
                                  ],
                                  onChanged: (v) => setState(() => _estadoFiltro = v),
                                ),
                                const SizedBox(height: 16),
                                ActionTile(
                                  icon: Icons.list_alt_rounded,
                                  label: 'Ver todas las prácticas',
                                  filled: true,
                                  onTap: () => context.push('/coordinador/practicas'),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Administración',
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
                                      icon: Icons.people_outline,
                                      label: 'Usuarios',
                                      onTap: () => context.push('/coordinador/usuarios'),
                                    ),
                                    ActionTile(
                                      icon: Icons.business_outlined,
                                      label: 'Empresas',
                                      color: AppColors.secondary,
                                      onTap: () => context.push('/coordinador/empresas'),
                                    ),
                                    ActionTile(
                                      icon: Icons.work_outline,
                                      label: 'Prácticas',
                                      color: AppColors.accent,
                                      onTap: () =>
                                          context.push('/coordinador/practicas-admin'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Prácticas activas',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                ..._dashboard!.practicas
                                    .where((p) =>
                                        _estadoFiltro == null ||
                                        p.estado == _estadoFiltro)
                                    .map(
                                      (p) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor: AppColors.primary
                                                          .withValues(alpha: 0.12),
                                                      child: Text(
                                                        p.estudianteNombre.isNotEmpty
                                                            ? p.estudianteNombre[0]
                                                                .toUpperCase()
                                                            : '?',
                                                        style: const TextStyle(
                                                          color: AppColors.primary,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            p.estudianteNombre,
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .titleSmall
                                                                ?.copyWith(
                                                                  fontWeight:
                                                                      FontWeight.w700,
                                                                ),
                                                          ),
                                                          Text(
                                                            p.empresaNombre,
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                  color: AppColors
                                                                      .textSecondary,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                ProgressCard(
                                                  titulo: 'Avance',
                                                  valor: p.horasAcumuladas,
                                                  maximo: p.horasRequeridas.toDouble(),
                                                  subtitulo:
                                                      '${p.actividadesPendientes} pendiente(s)',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
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
