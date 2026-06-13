import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/empresa_list_item_dto.dart';
import 'package:following_practices/front/components/empty_state.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/services/coordinador_service.dart';
import 'package:go_router/go_router.dart';

class EmpresasListPage extends StatefulWidget {
  const EmpresasListPage({super.key});

  @override
  State<EmpresasListPage> createState() => _EmpresasListPageState();
}

class _EmpresasListPageState extends State<EmpresasListPage> {
  final _service = CoordinadorService();
  List<EmpresaListItemDto> _empresas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final lista = await _service.listarEmpresas();
    setState(() {
      _empresas = lista;
      _cargando = false;
    });
  }

  Future<void> _eliminar(EmpresaListItemDto e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar empresa'),
        content: Text('¿Eliminar ${e.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _service.eliminarEmpresa(e.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Empresa eliminada.')));
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
      appBar: AppBar(title: const Text('Empresas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/coordinador/empresas/nueva');
          _cargar();
        },
        child: const Icon(Icons.add),
      ),
      body: _cargando
          ? const LoadingView()
          : _empresas.isEmpty
              ? const EmptyState(icon: Icons.business, mensaje: 'No hay empresas.')
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    itemCount: _empresas.length,
                    itemBuilder: (context, index) {
                      final e = _empresas[index];
                      return ListTile(
                        title: Text(e.nombre),
                        subtitle: Text('QR: ${e.qrToken} · ${e.practicasActivas} práctica(s) activa(s)'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'edit') {
                              await context.push('/coordinador/empresas/${e.id}');
                              _cargar();
                            } else if (v == 'delete') {
                              _eliminar(e);
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
    );
  }
}
