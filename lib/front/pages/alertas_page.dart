import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/alerta_dto.dart';
import 'package:following_practices/front/components/animated_fade_slide.dart';
import 'package:following_practices/front/components/empty_state.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/lib/theme/app_colors.dart';
import 'package:following_practices/front/services/alerta_service.dart';
import 'package:following_practices/front/services/auth_service.dart';

class AlertasPage extends StatefulWidget {
  const AlertasPage({super.key});

  @override
  State<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends State<AlertasPage> {
  final _alertaService = AlertaService();
  final _authService = AuthService();
  List<AlertaDto> _alertas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final sesion = _authService.sesionActual;
    if (sesion == null) return;
    final alertas = await _alertaService.listar(sesion.id);
    setState(() {
      _alertas = alertas;
      _cargando = false;
    });
  }

  Future<void> _marcarLeida(AlertaDto alerta) async {
    await _alertaService.marcarLeida(alerta.id);
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        backgroundColor: AppColors.surfaceCard,
      ),
      body: _cargando
          ? const LoadingView()
          : _alertas.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_none_outlined,
                  mensaje: 'No tienes alertas pendientes.',
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _alertas.length,
                    itemBuilder: (context, index) {
                      final a = _alertas[index];
                      return AnimatedFadeSlide(
                        delay: Duration(milliseconds: 50 * index),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Dismissible(
                            key: ValueKey(a.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _marcarLeida(a),
                            background: Container(
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 28),
                            ),
                            child: Card(
                              color: a.leida
                                  ? AppColors.surfaceCard
                                  : AppColors.primary.withValues(alpha: 0.04),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: (a.leida
                                            ? AppColors.textMuted
                                            : AppColors.warning)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    a.leida
                                        ? Icons.notifications_outlined
                                        : Icons.notifications_active_outlined,
                                    color: a.leida
                                        ? AppColors.textMuted
                                        : AppColors.warning,
                                  ),
                                ),
                                title: Text(
                                  a.titulo,
                                  style: TextStyle(
                                    fontWeight:
                                        a.leida ? FontWeight.w500 : FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  a.mensaje,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.textSecondary),
                                ),
                                trailing: a.leida
                                    ? null
                                    : Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: AppColors.warning,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
