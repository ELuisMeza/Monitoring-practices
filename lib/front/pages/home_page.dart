import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/resumen_horas_semanal_dto.dart';
import 'package:following_practices/front/services/actividad_service.dart';

/// Pantalla principal — consume directamente `front/services`.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _actividadService = ActividadService();

  ResumenHorasSemanalDto? _resumen;
  bool _cargando = true;
  String? _error;

  // TODO: reemplazar por el id del estudiante autenticado.
  static const _estudianteIdDemo = 1;

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resumen = await _actividadService.obtenerHorasUltimaSemana(
        _estudianteIdDemo,
      );

      setState(() {
        _resumen = resumen;
        _error = resumen == null ? 'Sin práctica activa.' : null;
        _cargando = false;
      });
    } catch (_) {
      setState(() {
        _error = 'No se pudo cargar el resumen.';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de Prácticas'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    final resumen = _resumen!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horas última semana',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('Total: ${resumen.totalHoras} h'),
          Text('Actividades: ${resumen.cantidadActividades}'),
          Text('Periodo: ${resumen.fechaInicio} → ${resumen.fechaFin}'),
        ],
      ),
    );
  }
}
