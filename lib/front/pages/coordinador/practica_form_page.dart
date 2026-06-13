import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/usuario_list_item_dto.dart';
import 'package:following_practices/back/entities/practica.dart';
import 'package:following_practices/back/entities/usuario.dart';
import 'package:following_practices/back/validators/input_validator.dart';
import 'package:following_practices/front/components/date_picker_field.dart';
import 'package:following_practices/front/services/coordinador_service.dart';
import 'package:go_router/go_router.dart';

class PracticaFormPage extends StatefulWidget {
  const PracticaFormPage({super.key, this.practicaId});

  final int? practicaId;

  @override
  State<PracticaFormPage> createState() => _PracticaFormPageState();
}

class _PracticaFormPageState extends State<PracticaFormPage> {
  final _service = CoordinadorService();
  final _formKey = GlobalKey<FormState>();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();
  final _horasController = TextEditingController(text: '240');

  List<UsuarioListItemDto> _estudiantes = [];
  List<UsuarioListItemDto> _tutores = [];
  List<({int id, String nombre})> _empresas = [];

  int? _estudianteId;
  int? _empresaId;
  int? _tutorId;
  String _estado = Practica.estadoActiva;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _cargando = true;
  bool _guardando = false;

  bool get _editando => widget.practicaId != null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final usuarios = await _service.listarUsuarios();
    final empresas = await _service.listarEmpresas();

    _estudiantes = usuarios.where((u) => u.rol == Usuario.rolEstudiante).toList();
    _tutores = usuarios.where((u) => u.rol == Usuario.rolTutor).toList();
    _empresas = empresas.map((e) => (id: e.id, nombre: e.nombre)).toList();

    if (_editando) {
      final practicas = await _service.listarPracticasAdmin();
      final p = practicas.firstWhere((x) => x.id == widget.practicaId);
      _estudianteId = p.estudianteId;
      _empresaId = p.empresaId;
      _tutorId = p.tutorId;
      _estado = p.estado;
      _fechaInicio = DateTime.parse(p.fechaInicio);
      _fechaInicioController.text = p.fechaInicio;
      if (p.fechaFin != null && p.fechaFin!.isNotEmpty) {
        _fechaFin = DateTime.parse(p.fechaFin!);
        _fechaFinController.text = p.fechaFin!;
      }
      _horasController.text = '${p.horasRequeridas}';
    }

    setState(() => _cargando = false);
  }

  @override
  void dispose() {
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _horasController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_estudianteId == null || _empresaId == null || _tutorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona estudiante, empresa y tutor.')),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      final horas = int.parse(_horasController.text);
      if (_editando) {
        await _service.actualizarPractica(
          id: widget.practicaId!,
          estudianteId: _estudianteId!,
          empresaId: _empresaId!,
          tutorId: _tutorId!,
          fechaInicio: _fechaInicioController.text,
          fechaFin: _fechaFinController.text.isEmpty ? null : _fechaFinController.text,
          horasRequeridas: horas,
          estado: _estado,
        );
      } else {
        await _service.crearPractica(
          estudianteId: _estudianteId!,
          empresaId: _empresaId!,
          tutorId: _tutorId!,
          fechaInicio: _fechaInicioController.text,
          fechaFin: _fechaFinController.text.isEmpty ? null : _fechaFinController.text,
          horasRequeridas: horas,
          estado: _estado,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Práctica guardada.')));
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
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar práctica' : 'Nueva práctica')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                initialValue: _estudianteId,
                decoration: const InputDecoration(labelText: 'Estudiante'),
                items: _estudiantes
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _estudianteId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _empresaId,
                decoration: const InputDecoration(labelText: 'Empresa'),
                items: _empresas
                    .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _empresaId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _tutorId,
                decoration: const InputDecoration(labelText: 'Tutor'),
                items: _tutores
                    .map((t) => DropdownMenuItem(value: t.id, child: Text(t.nombre)))
                    .toList(),
                validator: (v) => v == null ? 'Selecciona un tutor.' : null,
                onChanged: (v) => setState(() => _tutorId = v),
              ),
              const SizedBox(height: 12),
              DatePickerField(
                controller: _fechaInicioController,
                labelText: 'Fecha inicio',
                helpText: 'Fecha de inicio',
                onSelected: (fecha) {
                  setState(() {
                    _fechaInicio = fecha;
                    if (_fechaFin != null && _fechaFin!.isBefore(fecha)) {
                      _fechaFin = null;
                      _fechaFinController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              DatePickerField(
                controller: _fechaFinController,
                labelText: 'Fecha fin (opcional)',
                helpText: 'Fecha de fin',
                required: false,
                clearable: true,
                minSelectableDate: _fechaInicio,
                beforePick: () async {
                  if (_fechaInicio != null) return true;
                  if (!mounted) return false;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selecciona primero la fecha de inicio.')),
                  );
                  return false;
                },
                onSelected: (fecha) => setState(() => _fechaFin = fecha),
                onClear: () => setState(() => _fechaFin = null),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final error = InputValidator.fechaIso(value);
                  if (error != null) return error;
                  if (_fechaInicio != null) {
                    final fin = DateTime.parse(value);
                    if (fin.isBefore(_fechaInicio!)) {
                      return 'La fecha fin no puede ser anterior al inicio.';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _horasController,
                decoration: const InputDecoration(labelText: 'Horas requeridas'),
                keyboardType: TextInputType.number,
                validator: (v) => InputValidator.requiredText(v, label: 'Horas'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _estado,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const [
                  DropdownMenuItem(value: Practica.estadoActiva, child: Text('Activa')),
                  DropdownMenuItem(value: Practica.estadoCompletada, child: Text('Completada')),
                  DropdownMenuItem(value: Practica.estadoSuspendida, child: Text('Suspendida')),
                ],
                onChanged: (v) => setState(() => _estado = v!),
              ),
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
