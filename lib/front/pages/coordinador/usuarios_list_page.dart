import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/usuario_list_item_dto.dart';
import 'package:following_practices/back/entities/usuario.dart';
import 'package:following_practices/front/components/empty_state.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/services/coordinador_service.dart';
import 'package:go_router/go_router.dart';

class UsuariosListPage extends StatefulWidget {
  const UsuariosListPage({super.key});

  @override
  State<UsuariosListPage> createState() => _UsuariosListPageState();
}

class _UsuariosListPageState extends State<UsuariosListPage> {
  final _service = CoordinadorService();
  List<UsuarioListItemDto> _usuarios = [];
  bool _cargando = true;
  String? _rolFiltro;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final lista = await _service.listarUsuarios(rolFiltro: _rolFiltro);
    setState(() {
      _usuarios = lista;
      _cargando = false;
    });
  }

  Future<void> _eliminar(UsuarioListItemDto u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Eliminar a ${u.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _service.eliminarUsuario(u.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario eliminado.')));
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
      appBar: AppBar(title: const Text('Usuarios')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/coordinador/usuarios/nuevo');
          _cargar();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              initialValue: _rolFiltro,
              decoration: const InputDecoration(labelText: 'Filtrar por rol'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: Usuario.rolEstudiante, child: Text('Estudiante')),
                DropdownMenuItem(value: Usuario.rolTutor, child: Text('Tutor')),
                DropdownMenuItem(value: Usuario.rolSupervisor, child: Text('Supervisor')),
                DropdownMenuItem(value: Usuario.rolCoordinador, child: Text('Coordinador')),
              ],
              onChanged: (v) {
                setState(() => _rolFiltro = v);
                _cargar();
              },
            ),
          ),
          Expanded(
            child: _cargando
                ? const LoadingView()
                : _usuarios.isEmpty
                    ? const EmptyState(icon: Icons.people, mensaje: 'No hay usuarios.')
                    : RefreshIndicator(
                        onRefresh: _cargar,
                        child: ListView.builder(
                          itemCount: _usuarios.length,
                          itemBuilder: (context, index) {
                            final u = _usuarios[index];
                            return ListTile(
                              title: Text(u.nombre),
                              subtitle: Text('${u.email} · ${u.rol}'
                                  '${u.empresaNombre != null ? ' · ${u.empresaNombre}' : ''}'),
                              trailing: PopupMenuButton<String>(
                                onSelected: (v) async {
                                  if (v == 'edit') {
                                    await context.push('/coordinador/usuarios/${u.id}');
                                    _cargar();
                                  } else if (v == 'delete') {
                                    _eliminar(u);
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
