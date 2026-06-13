import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/actividad_detalle_dto.dart';
import 'package:following_practices/back/entities/actividad.dart';
import 'package:following_practices/back/validators/input_validator.dart';
import 'package:following_practices/front/components/estado_badge.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/services/actividad_service.dart';
import 'package:following_practices/front/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class RevisionDetailPage extends StatefulWidget {
  const RevisionDetailPage({super.key, required this.actividadId});

  final int actividadId;

  @override
  State<RevisionDetailPage> createState() => _RevisionDetailPageState();
}

class _RevisionDetailPageState extends State<RevisionDetailPage> {
  final _actividadService = ActividadService();
  final _authService = AuthService();
  final _observacionController = TextEditingController();
  ActividadDetalleDto? _detalle;
  bool _cargando = true;
  bool _guardando = false;
  String _estadoSeleccionado = Actividad.estadoObservado;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _observacionController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final detalle = await _actividadService.obtenerDetalle(widget.actividadId);
    setState(() {
      _detalle = detalle;
      _cargando = false;
    });
  }

  Future<void> _enviarRevision() async {
    final sesion = _authService.sesionActual;
    if (sesion == null) return;

    final error = InputValidator.requiredText(
      _observacionController.text,
      label: 'Observación',
    );
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _guardando = true);
    try {
      await _actividadService.revisar(
        actividadId: widget.actividadId,
        revisorId: sesion.id,
        nuevoEstado: _estadoSeleccionado,
        observacion: _observacionController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revisión registrada.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is StateError ? e.message : 'Error al revisar.')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revisar actividad')),
      body: _cargando
          ? const LoadingView()
          : _detalle == null
              ? const Center(child: Text('Actividad no encontrada.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_detalle!.estudianteNombre != null)
                      Text('Estudiante: ${_detalle!.estudianteNombre}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Text(_detalle!.descripcion)),
                        EstadoBadge(estado: _detalle!.estado),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Fecha: ${_detalle!.fecha} · ${_detalle!.horasCumplidas} h'),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      initialValue: _estadoSeleccionado,
                      decoration: const InputDecoration(labelText: 'Nuevo estado'),
                      items: const [
                        DropdownMenuItem(
                          value: Actividad.estadoObservado,
                          child: Text('Observado'),
                        ),
                        DropdownMenuItem(
                          value: Actividad.estadoAprobado,
                          child: Text('Aprobado'),
                        ),
                        DropdownMenuItem(
                          value: Actividad.estadoRechazado,
                          child: Text('Rechazado'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _estadoSeleccionado = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _observacionController,
                      decoration: const InputDecoration(
                        labelText: 'Observación',
                        hintText: 'Comentario para el estudiante',
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _guardando ? null : _enviarRevision,
                      child: _guardando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Enviar revisión'),
                    ),
                    const SizedBox(height: 24),
                    Text('Observaciones previas',
                        style: Theme.of(context).textTheme.titleMedium),
                    if (_detalle!.observaciones.isEmpty)
                      const Text('Sin observaciones previas.')
                    else
                      ..._detalle!.observaciones.map(
                        (o) => ListTile(
                          title: Text(o.autorNombre),
                          subtitle: Text(o.texto),
                        ),
                      ),
                  ],
                ),
    );
  }
}
