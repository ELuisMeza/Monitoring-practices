import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/actividad_list_item_dto.dart';
import 'package:following_practices/front/components/actividad_card.dart';
import 'package:following_practices/front/components/empty_state.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/services/actividad_service.dart';
import 'package:following_practices/front/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class RevisionQueuePage extends StatefulWidget {
  const RevisionQueuePage({
    super.key,
    required this.modo,
  });

  /// `tutor` o `supervisor`
  final String modo;

  @override
  State<RevisionQueuePage> createState() => _RevisionQueuePageState();
}

class _RevisionQueuePageState extends State<RevisionQueuePage> {
  final _actividadService = ActividadService();
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
    final pendientes = widget.modo == 'supervisor'
        ? await _actividadService.listarPendientesSupervisor(sesion.id)
        : await _actividadService.listarPendientesTutor(sesion.id);
    setState(() {
      _pendientes = pendientes;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.modo == 'supervisor' ? 'Validar actividades' : 'Revisar actividades',
        ),
      ),
      body: _cargando
          ? const LoadingView()
          : _pendientes.isEmpty
              ? const EmptyState(
                  icon: Icons.check_circle,
                  mensaje: 'No hay actividades pendientes.',
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _pendientes.length,
                    itemBuilder: (context, index) {
                      final a = _pendientes[index];
                      return ActividadCard(
                        actividad: a,
                        onTap: () => context.push('/revision/${a.id}'),
                      );
                    },
                  ),
                ),
    );
  }
}
