import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:following_practices/front/services/asistencia_service.dart';
import 'package:following_practices/front/services/auth_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final _asistenciaService = AsistenciaService();
  final _authService = AuthService();
  final _manualController = TextEditingController(text: 'DEMO-QR-TECH-001');
  bool _procesando = false;
  String? _ultimoResultado;

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _registrar(String token) async {
    if (_procesando) return;
    final sesion = _authService.sesionActual;
    if (sesion == null) return;

    setState(() {
      _procesando = true;
      _ultimoResultado = null;
    });

    try {
      final asistencia = await _asistenciaService.registrarPorQr(
        estudianteId: sesion.id,
        qrToken: token,
      );
      setState(() {
        _ultimoResultado = '${asistencia.tipo.toUpperCase()} registrada a las ${asistencia.hora}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_ultimoResultado!)),
        );
      }
    } catch (e) {
      final msg = e is StateError ? e.message : 'Error al registrar asistencia.';
      setState(() => _ultimoResultado = msg);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usarCamara = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return Scaffold(
      appBar: AppBar(title: const Text('Asistencia QR')),
      body: Column(
        children: [
          if (usarCamara)
            Expanded(
              flex: 2,
              child: MobileScanner(
                onDetect: (capture) {
                  final barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final value = barcode.rawValue;
                    if (value != null && value.isNotEmpty) {
                      _registrar(value);
                      break;
                    }
                  }
                },
              ),
            )
          else
            Expanded(
              flex: 1,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'En desktop, ingresa el token QR manualmente.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _manualController,
                  decoration: const InputDecoration(
                    labelText: 'Token QR manual',
                    hintText: 'DEMO-QR-TECH-001',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _procesando
                      ? null
                      : () => _registrar(_manualController.text),
                  child: _procesando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Registrar asistencia'),
                ),
                if (_ultimoResultado != null) ...[
                  const SizedBox(height: 12),
                  Text(_ultimoResultado!, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
