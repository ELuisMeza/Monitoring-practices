import 'package:flutter/material.dart';
import 'package:following_practices/back/validators/input_validator.dart';
import 'package:following_practices/front/components/date_picker_field.dart';
import 'package:following_practices/front/services/actividad_service.dart';
import 'package:following_practices/front/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class ActividadFormPage extends StatefulWidget {
  const ActividadFormPage({super.key});

  @override
  State<ActividadFormPage> createState() => _ActividadFormPageState();
}

class _ActividadFormPageState extends State<ActividadFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _horasController = TextEditingController();
  final _evidenciaController = TextEditingController();
  final _fechaController = TextEditingController(
    text: InputValidator.formatoFecha(DateTime.now()),
  );
  final _actividadService = ActividadService();
  final _authService = AuthService();
  bool _guardando = false;

  @override
  void dispose() {
    _descripcionController.dispose();
    _horasController.dispose();
    _evidenciaController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final sesion = _authService.sesionActual;
    if (sesion == null) return;

    setState(() => _guardando = true);
    try {
      await _actividadService.registrar(
        estudianteId: sesion.id,
        fecha: _fechaController.text.trim(),
        descripcion: _descripcionController.text,
        horasCumplidas: double.parse(_horasController.text.replaceAll(',', '.')),
        evidenciaUrl: _evidenciaController.text.isEmpty ? null : _evidenciaController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Actividad registrada.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is StateError ? e.message : 'Error al guardar.')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar actividad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DatePickerField(
                controller: _fechaController,
                labelText: 'Fecha',
                initialPickerDate: DateTime.now(),
                helpText: 'Fecha de la actividad',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator: (v) => InputValidator.requiredText(v, label: 'Descripción'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _horasController,
                decoration: const InputDecoration(labelText: 'Horas cumplidas'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: InputValidator.horasPositivas,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _evidenciaController,
                decoration: const InputDecoration(
                  labelText: 'Evidencia (URL o ruta local, opcional)',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
