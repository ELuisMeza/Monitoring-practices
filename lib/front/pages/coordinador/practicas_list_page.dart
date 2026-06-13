import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/dashboard_coordinador_dto.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/components/progress_card.dart';
import 'package:following_practices/front/services/coordinador_service.dart';

class PracticasListPage extends StatefulWidget {
  const PracticasListPage({super.key});

  @override
  State<PracticasListPage> createState() => _PracticasListPageState();
}

class _PracticasListPageState extends State<PracticasListPage> {
  final _coordinadorService = CoordinadorService();
  List<PracticaDashboardItemDto> _practicas = [];
  bool _cargando = true;
  String? _estadoFiltro;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final practicas = await _coordinadorService.listarPracticas(
      estadoFiltro: _estadoFiltro,
    );
    setState(() {
      _practicas = practicas;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prácticas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String?>(
              initialValue: _estadoFiltro,
              decoration: const InputDecoration(labelText: 'Estado'),
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
                : RefreshIndicator(
                    onRefresh: _cargar,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _practicas.length,
                      itemBuilder: (context, index) {
                        final p = _practicas[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.estudianteNombre,
                                    style: Theme.of(context).textTheme.titleSmall),
                                Text('${p.empresaNombre} · ${p.estado}'),
                                const SizedBox(height: 8),
                                ProgressCard(
                                  titulo: 'Horas',
                                  valor: p.horasAcumuladas,
                                  maximo: p.horasRequeridas.toDouble(),
                                ),
                              ],
                            ),
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
