import 'package:flutter/material.dart';
import 'package:following_practices/back/validators/input_validator.dart';
import 'package:following_practices/front/services/coordinador_service.dart';
import 'package:go_router/go_router.dart';

class EmpresaFormPage extends StatefulWidget {
  const EmpresaFormPage({super.key, this.empresaId});

  final int? empresaId;

  @override
  State<EmpresaFormPage> createState() => _EmpresaFormPageState();
}

class _EmpresaFormPageState extends State<EmpresaFormPage> {
  final _service = CoordinadorService();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _qrController = TextEditingController();
  final _rucController = TextEditingController();
  final _direccionController = TextEditingController();
  final _contactoNombreController = TextEditingController();
  final _contactoEmailController = TextEditingController();
  bool _guardando = false;

  bool get _editando => widget.empresaId != null;

  @override
  void initState() {
    super.initState();
    if (_editando) _cargar();
  }

  Future<void> _cargar() async {
    if (!_editando) return;
    final empresa = await _service.obtenerEmpresa(widget.empresaId!);
    if (empresa == null) return;
    _nombreController.text = empresa.nombre;
    _qrController.text = empresa.qrToken;
    _rucController.text = empresa.ruc ?? '';
    _direccionController.text = empresa.direccion ?? '';
    _contactoNombreController.text = empresa.contactoNombre ?? '';
    _contactoEmailController.text = empresa.contactoEmail ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _qrController.dispose();
    _rucController.dispose();
    _direccionController.dispose();
    _contactoNombreController.dispose();
    _contactoEmailController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      if (_editando) {
        await _service.actualizarEmpresa(
          id: widget.empresaId!,
          nombre: _nombreController.text,
          qrToken: _qrController.text,
          ruc: _rucController.text.isEmpty ? null : _rucController.text,
          direccion: _direccionController.text.isEmpty ? null : _direccionController.text,
          contactoNombre: _contactoNombreController.text.isEmpty ? null : _contactoNombreController.text,
          contactoEmail: _contactoEmailController.text.isEmpty ? null : _contactoEmailController.text,
        );
      } else {
        await _service.crearEmpresa(
          nombre: _nombreController.text,
          qrToken: _qrController.text,
          ruc: _rucController.text.isEmpty ? null : _rucController.text,
          direccion: _direccionController.text.isEmpty ? null : _direccionController.text,
          contactoNombre: _contactoNombreController.text.isEmpty ? null : _contactoNombreController.text,
          contactoEmail: _contactoEmailController.text.isEmpty ? null : _contactoEmailController.text,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Empresa guardada.')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is StateError ? e.message : e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar empresa' : 'Nueva empresa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => InputValidator.requiredText(v, label: 'Nombre'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qrController,
                decoration: const InputDecoration(labelText: 'Token QR'),
                validator: (v) => InputValidator.requiredText(v, label: 'Token QR'),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _rucController, decoration: const InputDecoration(labelText: 'RUC')),
              const SizedBox(height: 12),
              TextFormField(controller: _direccionController, decoration: const InputDecoration(labelText: 'Dirección')),
              const SizedBox(height: 12),
              TextFormField(controller: _contactoNombreController, decoration: const InputDecoration(labelText: 'Contacto')),
              const SizedBox(height: 12),
              TextFormField(controller: _contactoEmailController, decoration: const InputDecoration(labelText: 'Email contacto')),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
