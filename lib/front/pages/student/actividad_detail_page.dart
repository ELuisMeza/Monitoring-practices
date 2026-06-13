import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/actividad_detalle_dto.dart';
import 'package:following_practices/front/components/estado_badge.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/services/actividad_service.dart';

class ActividadDetailPage extends StatefulWidget {
  const ActividadDetailPage({super.key, required this.actividadId});

  final int actividadId;

  @override
  State<ActividadDetailPage> createState() => _ActividadDetailPageState();
}

class _ActividadDetailPageState extends State<ActividadDetailPage> {
  final _actividadService = ActividadService();
  ActividadDetalleDto? _detalle;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final detalle = await _actividadService.obtenerDetalle(widget.actividadId);
    setState(() {
      _detalle = detalle;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle actividad')),
      body: _cargando
          ? const LoadingView()
          : _detalle == null
              ? const Center(child: Text('Actividad no encontrada.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _detalle!.descripcion,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        EstadoBadge(estado: _detalle!.estado),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Fecha: ${_detalle!.fecha}'),
                    Text('Horas: ${_detalle!.horasCumplidas}'),
                    if (_detalle!.evidenciaUrl != null)
                      Text('Evidencia: ${_detalle!.evidenciaUrl}'),
                    const SizedBox(height: 24),
                    Text('Observaciones',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_detalle!.observaciones.isEmpty)
                      const Text('Sin observaciones.')
                    else
                      ..._detalle!.observaciones.map(
                        (o) => Card(
                          child: ListTile(
                            title: Text(o.autorNombre),
                            subtitle: Text(o.texto),
                            trailing: Text(
                              o.createdAt,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
