import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/alerta_dto.dart';
import 'package:following_practices/front/components/empty_state.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/services/alerta_service.dart';
import 'package:following_practices/front/services/auth_service.dart';

class AlertasPage extends StatefulWidget {
  const AlertasPage({super.key});

  @override
  State<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends State<AlertasPage> {
  final _alertaService = AlertaService();
  final _authService = AuthService();
  List<AlertaDto> _alertas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final sesion = _authService.sesionActual;
    if (sesion == null) return;
    final alertas = await _alertaService.listar(sesion.id);
    setState(() {
      _alertas = alertas;
      _cargando = false;
    });
  }

  Future<void> _marcarLeida(AlertaDto alerta) async {
    await _alertaService.marcarLeida(alerta.id);
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      body: _cargando
          ? const LoadingView()
          : _alertas.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_none,
                  mensaje: 'No tienes alertas pendientes.',
                )
              : RefreshIndicator(
                  onRefresh: _cargar,
                  child: ListView.builder(
                    itemCount: _alertas.length,
                    itemBuilder: (context, index) {
                      final a = _alertas[index];
                      return Dismissible(
                        key: ValueKey(a.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _marcarLeida(a),
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.check, color: Colors.white),
                        ),
                        child: ListTile(
                          leading: Icon(
                            a.leida ? Icons.notifications : Icons.notifications_active,
                            color: a.leida ? Colors.grey : Colors.orange,
                          ),
                          title: Text(a.titulo),
                          subtitle: Text(a.mensaje),
                          trailing: a.leida ? null : const Icon(Icons.circle, size: 10, color: Colors.orange),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
