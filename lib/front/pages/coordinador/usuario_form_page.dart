import 'package:flutter/material.dart';
import 'package:following_practices/back/dtos/empresa_list_item_dto.dart';
import 'package:following_practices/back/entities/usuario.dart';
import 'package:following_practices/back/validators/input_validator.dart';
import 'package:following_practices/front/services/coordinador_service.dart';
import 'package:go_router/go_router.dart';

class UsuarioFormPage extends StatefulWidget {
  const UsuarioFormPage({super.key, this.usuarioId});

  final int? usuarioId;

  @override
  State<UsuarioFormPage> createState() => _UsuarioFormPageState();
}

class _UsuarioFormPageState extends State<UsuarioFormPage> {
  final _service = CoordinadorService();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telefonoController = TextEditingController();

  String _rol = Usuario.rolEstudiante;
  int? _empresaId;
  List<EmpresaListItemDto> _empresas = [];
  bool _cargando = true;
  bool _guardando = false;

  bool get _editando => widget.usuarioId != null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _empresas = await _service.listarEmpresas();
    if (_editando) {
      final usuarios = await _service.listarUsuarios();
      final u = usuarios.firstWhere((x) => x.id == widget.usuarioId);
      _nombreController.text = u.nombre;
      _emailController.text = u.email;
      _telefonoController.text = u.telefono ?? '';
      _rol = u.rol;
      _empresaId = u.empresaId;
    }
    setState(() => _cargando = false);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rol == Usuario.rolSupervisor && _empresaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una empresa para el supervisor.')),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      if (_editando) {
        await _service.actualizarUsuario(
          id: widget.usuarioId!,
          nombre: _nombreController.text,
          email: _emailController.text,
          rol: _rol,
          telefono: _telefonoController.text.isEmpty ? null : _telefonoController.text,
          empresaId: _empresaId,
          nuevaPassword: _passwordController.text.isEmpty ? null : _passwordController.text,
        );
      } else {
        await _service.crearUsuario(
          nombre: _nombreController.text,
          email: _emailController.text,
          password: _passwordController.text,
          rol: _rol,
          telefono: _telefonoController.text.isEmpty ? null : _telefonoController.text,
          empresaId: _empresaId,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario guardado.')));
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
      appBar: AppBar(title: Text(_editando ? 'Editar usuario' : 'Nuevo usuario')),
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
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: InputValidator.email,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: _editando ? 'Nueva contraseña (opcional)' : 'Contraseña',
                ),
                obscureText: true,
                validator: _editando ? null : InputValidator.password,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _rol,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: Usuario.rolEstudiante, child: Text('Estudiante')),
                  DropdownMenuItem(value: Usuario.rolTutor, child: Text('Tutor')),
                  DropdownMenuItem(value: Usuario.rolSupervisor, child: Text('Supervisor')),
                  DropdownMenuItem(value: Usuario.rolCoordinador, child: Text('Coordinador')),
                ],
                onChanged: (v) => setState(() {
                  _rol = v!;
                  if (_rol != Usuario.rolSupervisor) _empresaId = null;
                }),
              ),
              if (_rol == Usuario.rolSupervisor) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: _empresaId,
                  decoration: const InputDecoration(labelText: 'Empresa'),
                  items: _empresas
                      .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre)))
                      .toList(),
                  onChanged: (v) => setState(() => _empresaId = v),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
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
