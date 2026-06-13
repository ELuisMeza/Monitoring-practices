import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/reporte_semanal_detallado_dto.dart';
import 'package:following_practices/front/components/empty_state.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/services/actividad_service.dart';
import 'package:following_practices/front/services/auth_service.dart';

class ReporteSemanalPage extends StatefulWidget {
  const ReporteSemanalPage({super.key});

  @override
  State<ReporteSemanalPage> createState() => _ReporteSemanalPageState();
}

class _ReporteSemanalPageState extends State<ReporteSemanalPage> {
  final _actividadService = ActividadService();
  final _authService = AuthService();
  ReporteSemanalDetalladoDto? _reporte;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final sesion = _authService.sesionActual;
    if (sesion == null) return;
    final reporte = await _actividadService.obtenerReporteSemanal(sesion.id);
    setState(() {
      _reporte = reporte;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte semanal')),
      body: _cargando
          ? const LoadingView()
          : _reporte == null
              ? const EmptyState(
                  icon: Icons.bar_chart,
                  mensaje: 'No hay datos para el reporte semanal.',
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Periodo: ${_reporte!.fechaInicio} → ${_reporte!.fechaFin}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Total: ${_reporte!.totalHoras} h'),
                    Text('Actividades: ${_reporte!.cantidadActividades}'),
                    const SizedBox(height: 24),
                    Text('Horas por día',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ..._reporte!.horasPorDia.entries.map(
                      (e) => ListTile(
                        title: Text(e.key),
                        trailing: Text('${e.value} h'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Actividades',
                        style: Theme.of(context).textTheme.titleMedium),
                    ..._reporte!.actividades.map(
                      (a) => ListTile(
                        title: Text(a.descripcion),
                        subtitle: Text(a.fecha),
                        trailing: Text('${a.horasCumplidas} h'),
                      ),
                    ),
                  ],
                ),
    );
  }
}
