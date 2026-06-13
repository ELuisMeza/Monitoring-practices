import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/practica_admin_item_dto.dart';
import 'package:following_practices/front/components/empty_state.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/services/coordinador_service.dart';
import 'package:go_router/go_router.dart';

class PracticasAdminListPage extends StatefulWidget {
  const PracticasAdminListPage({super.key});

  @override
  State<PracticasAdminListPage> createState() => _PracticasAdminListPageState();
}

class _PracticasAdminListPageState extends State<PracticasAdminListPage> {
  final _service = CoordinadorService();
  List<PracticaAdminItemDto> _practicas = [];
  bool _cargando = true;
  String? _estadoFiltro;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final lista = await _service.listarPracticasAdmin(estadoFiltro: _estadoFiltro);
    setState(() {
      _practicas = lista;
      _cargando = false;
    });
  }

  Future<void> _eliminar(PracticaAdminItemDto p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar práctica'),
        content: Text('¿Eliminar práctica de ${p.estudianteNombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _service.eliminarPractica(p.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Práctica eliminada.')));
        _cargar();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is StateError ? e.message : 'Error al eliminar.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prácticas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/coordinador/practicas-admin/nueva');
          _cargar();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              initialValue: _estadoFiltro,
              decoration: const InputDecoration(labelText: 'Filtrar por estado'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todas')),
                DropdownMenuItem(value: 'activa', child: Text('Activas')),
                DropdownMenuItem(value: 'completada', child: Text('Completadas')),
                DropdownMenuItem(value: 'suspendida', child: Text('Suspendidas')),
              ],
              onChanged: (v) {
                setState(() => _estadoFiltro = v);
                _cargar();
              },
            ),
          ),
          Expanded(
            child: _cargando
                ? const LoadingView()
                : _practicas.isEmpty
                    ? const EmptyState(icon: Icons.work, mensaje: 'No hay prácticas.')
                    : RefreshIndicator(
                        onRefresh: _cargar,
                        child: ListView.builder(
                          itemCount: _practicas.length,
                          itemBuilder: (context, index) {
                            final p = _practicas[index];
                            return ListTile(
                              title: Text(p.estudianteNombre),
                              subtitle: Text(
                                '${p.empresaNombre} · ${p.estado}\n'
                                'Tutor: ${p.tutorNombre ?? '—'} · Sup.: ${p.supervisorNombre ?? '—'}',
                              ),
                              isThreeLine: true,
                              trailing: PopupMenuButton<String>(
                                onSelected: (v) async {
                                  if (v == 'edit') {
                                    await context.push('/coordinador/practicas-admin/${p.id}');
                                    _cargar();
                                  } else if (v == 'delete') {
                                    _eliminar(p);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
