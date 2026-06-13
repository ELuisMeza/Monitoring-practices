import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/actividad_list_item_dto.dart';
import 'package:following_practices/front/components/actividad_card.dart';
import 'package:following_practices/front/components/empty_state.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/services/actividad_service.dart';
import 'package:following_practices/front/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class ActividadListPage extends StatefulWidget {
  const ActividadListPage({super.key});

  @override
  State<ActividadListPage> createState() => _ActividadListPageState();
}

class _ActividadListPageState extends State<ActividadListPage> {
  final _actividadService = ActividadService();
  final _authService = AuthService();
  List<ActividadListItemDto> _actividades = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final sesion = _authService.sesionActual;
    if (sesion == null) return;
    setState(() => _cargando = true);
    final lista = await _actividadService.listarPorEstudiante(sesion.id);
    setState(() {
      _actividades = lista;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis actividades')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/estudiante/actividad/nueva'),
        child: const Icon(Icons.add),
      ),
      body: _cargando
          ? const LoadingView()
          : _actividades.isEmpty
              ? EmptyState(
                  icon: Icons.assignment,
                  mensaje: 'Aún no has registrado actividades.',
                  accion: FilledButton(
                    onPressed: () => context.push('/estudiante/actividad/nueva'),
                    child: const Text('Registrar primera actividad'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _actividades.length,
                    itemBuilder: (context, index) {
                      final a = _actividades[index];
                      return ActividadCard(
                        actividad: a,
                        onTap: () => context.push('/estudiante/actividad/${a.id}'),
                      );
                    },
                  ),
                ),
    );
  }
}
