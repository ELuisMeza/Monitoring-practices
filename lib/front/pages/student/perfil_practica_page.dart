import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/asistencia_dto.dart';
import 'package:following_practices/back/dtos/practica_resumen_dto.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/components/progress_card.dart';
import 'package:following_practices/front/services/asistencia_service.dart';
import 'package:following_practices/front/services/auth_service.dart';
import 'package:following_practices/front/services/practica_service.dart';

class PerfilPracticaPage extends StatefulWidget {
  const PerfilPracticaPage({super.key});

  @override
  State<PerfilPracticaPage> createState() => _PerfilPracticaPageState();
}

class _PerfilPracticaPageState extends State<PerfilPracticaPage> {
  final _practicaService = PracticaService();
  final _asistenciaService = AsistenciaService();
  final _authService = AuthService();
  PracticaResumenDto? _practica;
  List<AsistenciaDto> _asistencias = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final sesion = _authService.sesionActual;
    if (sesion == null) return;
    final practica = await _practicaService.obtenerPracticaActiva(sesion.id);
    final asistencias = await _asistenciaService.listarHoyEstudiante(sesion.id);
    setState(() {
      _practica = practica;
      _asistencias = asistencias;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi práctica')),
      body: _cargando
          ? const LoadingView()
          : _practica == null
              ? const Center(child: Text('Sin práctica activa.'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(_practica!.empresaNombre,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Inicio: ${_practica!.fechaInicio}'),
                    if (_practica!.fechaFin != null)
                      Text('Fin: ${_practica!.fechaFin}'),
                    if (_practica!.tutorNombre != null)
                      Text('Tutor: ${_practica!.tutorNombre}'),
                    if (_practica!.supervisorNombre != null)
                      Text('Supervisor: ${_practica!.supervisorNombre}'),
                    const SizedBox(height: 16),
                    ProgressCard(
                      titulo: 'Progreso de horas',
                      valor: _practica!.horasAcumuladas,
                      maximo: _practica!.horasRequeridas.toDouble(),
                    ),
                    const SizedBox(height: 24),
                    Text('Asistencias de hoy',
                        style: Theme.of(context).textTheme.titleMedium),
                    if (_asistencias.isEmpty)
                      const Text('Sin registros hoy.')
                    else
                      ..._asistencias.map(
                        (a) => ListTile(
                          leading: Icon(
                            a.tipo == 'entrada' ? Icons.login : Icons.logout,
                          ),
                          title: Text(a.tipo.toUpperCase()),
                          trailing: Text(a.hora),
                        ),
                      ),
                  ],
                ),
    );
  }
}
