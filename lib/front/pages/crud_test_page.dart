import 'package:flutter/material.dart';
import 'package:following_practices/back/entities/actividad.dart';
import 'package:following_practices/back/entities/asistencia.dart';
import 'package:following_practices/back/entities/empresa.dart';
import 'package:following_practices/back/entities/observacion.dart';
import 'package:following_practices/back/entities/practica.dart';
import 'package:following_practices/back/entities/usuario.dart';
import 'package:following_practices/front/services/crud_test_service.dart';

/// Pantalla de prueba CRUD para todas las tablas. Solo desarrollo.
class CrudTestPage extends StatefulWidget {
  const CrudTestPage({super.key});

  @override
  State<CrudTestPage> createState() => _CrudTestPageState();
}

class _CrudTestPageState extends State<CrudTestPage>
    with SingleTickerProviderStateMixin {
  final _service = CrudTestService();
  late final TabController _tabs;

  String? _status;
  bool _ready = false;

  // Controllers compartidos por pestaña
  final _c = <String, TextEditingController>{};

  TextEditingController _ctrl(String key, [String? value]) {
    final controller =
        _c.putIfAbsent(key, () => TextEditingController());
    if (value != null) controller.text = value;
    return controller;
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this);
    _init();
  }

  Future<void> _init() async {
    try {
      final dbPath = await _service.databasePath();
      final applied = await _service.ensureSchema();
      setState(() {
        _ready = true;
        _status = 'BD: $dbPath\n'
            '${applied.isEmpty ? 'Esquema al día.' : 'Migraciones aplicadas: ${applied.join(', ')}'}';
      });
      await _reloadAll();
    } catch (e) {
      setState(() => _status = 'Error init: $e');
    }
  }

  // Datos en memoria
  List<Usuario> _usuarios = [];
  List<Empresa> _empresas = [];
  List<Practica> _practicas = [];
  List<Actividad> _actividades = [];
  List<Observacion> _observaciones = [];
  List<Asistencia> _asistencias = [];

  int? _editUsuarioId;
  int? _editEmpresaId;
  int? _editPracticaId;
  int? _editActividadId;
  int? _editObservacionId;
  int? _editAsistenciaId;

  Future<void> _reloadAll() async {
    if (!_ready) return;
    final u = await _service.listUsuarios();
    final e = await _service.listEmpresas();
    final p = await _service.listPracticas();
    final a = await _service.listActividades();
    final o = await _service.listObservaciones();
    final s = await _service.listAsistencias();
    if (!mounted) return;
    setState(() {
      _usuarios = u;
      _empresas = e;
      _practicas = p;
      _actividades = a;
      _observaciones = o;
      _asistencias = s;
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
      await _reloadAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OK')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _clearControllers(Iterable<String> keys) {
    for (final k in keys) {
      _c[k]?.clear();
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD prueba BD'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Usuarios'),
            Tab(text: 'Empresas'),
            Tab(text: 'Prácticas'),
            Tab(text: 'Actividades'),
            Tab(text: 'Observaciones'),
            Tab(text: 'Asistencias'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_status != null)
            Material(
              color: Colors.blue.shade50,
              child: ListTile(
                dense: true,
                title: Text(_status!, style: const TextStyle(fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _reloadAll,
                ),
              ),
            ),
          Expanded(
            child: !_ready
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _tabUsuarios(),
                      _tabEmpresas(),
                      _tabPracticas(),
                      _tabActividades(),
                      _tabObservaciones(),
                      _tabAsistencias(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _field(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: _ctrl(key),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _btn(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: ElevatedButton(onPressed: onTap, child: Text(label)),
    );
  }

  Widget _listHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }

  // --- USUARIOS ---

  Widget _tabUsuarios() {
    return _scroll([
      _field('u_nombre', 'nombre'),
      _field('u_email', 'email'),
      _field('u_pass', 'password_hash'),
      _field('u_rol', 'rol (estudiante/tutor/...)'),
      _field('u_tel', 'telefono (opcional)'),
      Wrap(
        children: [
          _btn(_editUsuarioId == null ? 'Crear' : 'Actualizar', () {
            _run(() async {
              if (_editUsuarioId == null) {
                await _service.createUsuario(
                  nombre: _ctrl('u_nombre').text,
                  email: _ctrl('u_email').text,
                  passwordHash: _ctrl('u_pass').text,
                  rol: _ctrl('u_rol').text,
                  telefono: _opt(_ctrl('u_tel').text),
                );
              } else {
                await _service.updateUsuario(Usuario(
                  id: _editUsuarioId,
                  nombre: _ctrl('u_nombre').text,
                  email: _ctrl('u_email').text,
                  passwordHash: _ctrl('u_pass').text,
                  rol: _ctrl('u_rol').text,
                  telefono: _opt(_ctrl('u_tel').text),
                ));
                _editUsuarioId = null;
              }
              _clearControllers(['u_nombre', 'u_email', 'u_pass', 'u_rol', 'u_tel']);
            });
          }),
          if (_editUsuarioId != null)
            _btn('Cancelar', () => setState(() => _editUsuarioId = null)),
        ],
      ),
      _listHeader('Registros (${_usuarios.length})'),
      ..._usuarios.map((u) => ListTile(
            title: Text('#${u.id} ${u.nombre}'),
            subtitle: Text('${u.email} · ${u.rol}'),
            onTap: () => setState(() {
              _editUsuarioId = u.id;
              _ctrl('u_nombre', u.nombre);
              _ctrl('u_email', u.email);
              _ctrl('u_pass', u.passwordHash);
              _ctrl('u_rol', u.rol);
              _ctrl('u_tel', u.telefono ?? '');
            }),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _run(() => _service.deleteUsuario(u.id!)),
            ),
          )),
    ]);
  }

  // --- EMPRESAS ---

  Widget _tabEmpresas() {
    return _scroll([
      _field('e_nombre', 'nombre'),
      _field('e_qr', 'qr_token'),
      _field('e_ruc', 'ruc'),
      _field('e_dir', 'direccion'),
      _field('e_cn', 'contacto_nombre'),
      _field('e_ce', 'contacto_email'),
      Wrap(
        children: [
          _btn(_editEmpresaId == null ? 'Crear' : 'Actualizar', () {
            _run(() async {
              if (_editEmpresaId == null) {
                await _service.createEmpresa(
                  nombre: _ctrl('e_nombre').text,
                  qrToken: _ctrl('e_qr').text,
                  ruc: _opt(_ctrl('e_ruc').text),
                  direccion: _opt(_ctrl('e_dir').text),
                  contactoNombre: _opt(_ctrl('e_cn').text),
                  contactoEmail: _opt(_ctrl('e_ce').text),
                );
              } else {
                await _service.updateEmpresa(Empresa(
                  id: _editEmpresaId,
                  nombre: _ctrl('e_nombre').text,
                  qrToken: _ctrl('e_qr').text,
                  ruc: _opt(_ctrl('e_ruc').text),
                  direccion: _opt(_ctrl('e_dir').text),
                  contactoNombre: _opt(_ctrl('e_cn').text),
                  contactoEmail: _opt(_ctrl('e_ce').text),
                ));
                _editEmpresaId = null;
              }
              _clearControllers(['e_nombre', 'e_qr', 'e_ruc', 'e_dir', 'e_cn', 'e_ce']);
            });
          }),
          if (_editEmpresaId != null)
            _btn('Cancelar', () => setState(() => _editEmpresaId = null)),
        ],
      ),
      _listHeader('Registros (${_empresas.length})'),
      ..._empresas.map((e) => ListTile(
            title: Text('#${e.id} ${e.nombre}'),
            subtitle: Text('qr: ${e.qrToken}'),
            onTap: () => setState(() {
              _editEmpresaId = e.id;
              _ctrl('e_nombre', e.nombre);
              _ctrl('e_qr', e.qrToken);
              _ctrl('e_ruc', e.ruc ?? '');
              _ctrl('e_dir', e.direccion ?? '');
              _ctrl('e_cn', e.contactoNombre ?? '');
              _ctrl('e_ce', e.contactoEmail ?? '');
            }),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _run(() => _service.deleteEmpresa(e.id!)),
            ),
          )),
    ]);
  }

  // --- PRACTICAS ---

  Widget _tabPracticas() {
    return _scroll([
      const Text('Crear usuario y empresa antes.', style: TextStyle(fontSize: 12)),
      _field('p_est', 'estudiante_id'),
      _field('p_emp', 'empresa_id'),
      _field('p_tut', 'tutor_id (opcional)'),
      _field('p_sup', 'supervisor_id (opcional)'),
      _field('p_ini', 'fecha_inicio YYYY-MM-DD'),
      _field('p_fin', 'fecha_fin (opcional)'),
      _field('p_horas', 'horas_requeridas'),
      _field('p_estado', 'estado (activa/completada/suspendida)'),
      Wrap(
        children: [
          _btn(_editPracticaId == null ? 'Crear' : 'Actualizar', () {
            _run(() async {
              if (_editPracticaId == null) {
                await _service.createPractica(
                  estudianteId: int.parse(_ctrl('p_est').text),
                  empresaId: int.parse(_ctrl('p_emp').text),
                  tutorId: _optInt(_ctrl('p_tut').text),
                  supervisorId: _optInt(_ctrl('p_sup').text),
                  fechaInicio: _ctrl('p_ini').text,
                  fechaFin: _opt(_ctrl('p_fin').text),
                  horasRequeridas: int.parse(_ctrl('p_horas').text),
                  estado: _ctrl('p_estado').text,
                );
              } else {
                await _service.updatePractica(Practica(
                  id: _editPracticaId,
                  estudianteId: int.parse(_ctrl('p_est').text),
                  empresaId: int.parse(_ctrl('p_emp').text),
                  tutorId: _optInt(_ctrl('p_tut').text),
                  supervisorId: _optInt(_ctrl('p_sup').text),
                  fechaInicio: _ctrl('p_ini').text,
                  fechaFin: _opt(_ctrl('p_fin').text),
                  horasRequeridas: int.parse(_ctrl('p_horas').text),
                  estado: _ctrl('p_estado').text,
                ));
                _editPracticaId = null;
              }
            });
          }),
          if (_editPracticaId != null)
            _btn('Cancelar', () => setState(() => _editPracticaId = null)),
        ],
      ),
      _listHeader('Registros (${_practicas.length})'),
      ..._practicas.map((p) => ListTile(
            title: Text('#${p.id} est:${p.estudianteId} emp:${p.empresaId}'),
            subtitle: Text('${p.fechaInicio} · ${p.estado}'),
            onTap: () => setState(() {
              _editPracticaId = p.id;
              _ctrl('p_est', '${p.estudianteId}');
              _ctrl('p_emp', '${p.empresaId}');
              _ctrl('p_tut', p.tutorId?.toString() ?? '');
              _ctrl('p_sup', p.supervisorId?.toString() ?? '');
              _ctrl('p_ini', p.fechaInicio);
              _ctrl('p_fin', p.fechaFin ?? '');
              _ctrl('p_horas', '${p.horasRequeridas}');
              _ctrl('p_estado', p.estado);
            }),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _run(() => _service.deletePractica(p.id!)),
            ),
          )),
    ]);
  }

  // --- ACTIVIDADES ---

  Widget _tabActividades() {
    return _scroll([
      _field('a_prac', 'practica_id'),
      _field('a_fecha', 'fecha YYYY-MM-DD'),
      _field('a_desc', 'descripcion'),
      _field('a_horas', 'horas_cumplidas'),
      _field('a_est', 'estado (registrado/observado/aprobado/rechazado)'),
      _field('a_url', 'evidencia_url (opcional)'),
      Wrap(
        children: [
          _btn(_editActividadId == null ? 'Crear' : 'Actualizar', () {
            _run(() async {
              if (_editActividadId == null) {
                await _service.createActividad(
                  practicaId: int.parse(_ctrl('a_prac').text),
                  fecha: _ctrl('a_fecha').text,
                  descripcion: _ctrl('a_desc').text,
                  horasCumplidas: double.parse(_ctrl('a_horas').text),
                  estado: _ctrl('a_est').text,
                  evidenciaUrl: _opt(_ctrl('a_url').text),
                );
              } else {
                await _service.updateActividad(Actividad(
                  id: _editActividadId,
                  practicaId: int.parse(_ctrl('a_prac').text),
                  fecha: _ctrl('a_fecha').text,
                  descripcion: _ctrl('a_desc').text,
                  horasCumplidas: double.parse(_ctrl('a_horas').text),
                  estado: _ctrl('a_est').text,
                  evidenciaUrl: _opt(_ctrl('a_url').text),
                ));
                _editActividadId = null;
              }
            });
          }),
          if (_editActividadId != null)
            _btn('Cancelar', () => setState(() => _editActividadId = null)),
        ],
      ),
      _listHeader('Registros (${_actividades.length})'),
      ..._actividades.map((a) => ListTile(
            title: Text('#${a.id} practica:${a.practicaId}'),
            subtitle: Text('${a.fecha} · ${a.horasCumplidas}h · ${a.descripcion}'),
            onTap: () => setState(() {
              _editActividadId = a.id;
              _ctrl('a_prac', '${a.practicaId}');
              _ctrl('a_fecha', a.fecha);
              _ctrl('a_desc', a.descripcion);
              _ctrl('a_horas', '${a.horasCumplidas}');
              _ctrl('a_est', a.estado);
              _ctrl('a_url', a.evidenciaUrl ?? '');
            }),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _run(() => _service.deleteActividad(a.id!)),
            ),
          )),
    ]);
  }

  // --- OBSERVACIONES ---

  Widget _tabObservaciones() {
    return _scroll([
      _field('o_act', 'actividad_id'),
      _field('o_user', 'usuario_id'),
      _field('o_txt', 'texto'),
      Wrap(
        children: [
          _btn(_editObservacionId == null ? 'Crear' : 'Actualizar', () {
            _run(() async {
              if (_editObservacionId == null) {
                await _service.createObservacion(
                  actividadId: int.parse(_ctrl('o_act').text),
                  usuarioId: int.parse(_ctrl('o_user').text),
                  texto: _ctrl('o_txt').text,
                );
              } else {
                await _service.updateObservacion(Observacion(
                  id: _editObservacionId,
                  actividadId: int.parse(_ctrl('o_act').text),
                  usuarioId: int.parse(_ctrl('o_user').text),
                  texto: _ctrl('o_txt').text,
                ));
                _editObservacionId = null;
              }
            });
          }),
          if (_editObservacionId != null)
            _btn('Cancelar', () => setState(() => _editObservacionId = null)),
        ],
      ),
      _listHeader('Registros (${_observaciones.length})'),
      ..._observaciones.map((o) => ListTile(
            title: Text('#${o.id} act:${o.actividadId}'),
            subtitle: Text(o.texto),
            onTap: () => setState(() {
              _editObservacionId = o.id;
              _ctrl('o_act', '${o.actividadId}');
              _ctrl('o_user', '${o.usuarioId}');
              _ctrl('o_txt', o.texto);
            }),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _run(() => _service.deleteObservacion(o.id!)),
            ),
          )),
    ]);
  }

  // --- ASISTENCIAS ---

  Widget _tabAsistencias() {
    return _scroll([
      _field('s_prac', 'practica_id'),
      _field('s_emp', 'empresa_id'),
      _field('s_fecha', 'fecha YYYY-MM-DD'),
      _field('s_hora', 'hora HH:MM'),
      _field('s_tipo', 'tipo (entrada/salida)'),
      Wrap(
        children: [
          _btn(_editAsistenciaId == null ? 'Crear' : 'Actualizar', () {
            _run(() async {
              if (_editAsistenciaId == null) {
                await _service.createAsistencia(
                  practicaId: int.parse(_ctrl('s_prac').text),
                  empresaId: int.parse(_ctrl('s_emp').text),
                  fecha: _ctrl('s_fecha').text,
                  hora: _ctrl('s_hora').text,
                  tipo: _ctrl('s_tipo').text,
                );
              } else {
                await _service.updateAsistencia(Asistencia(
                  id: _editAsistenciaId,
                  practicaId: int.parse(_ctrl('s_prac').text),
                  empresaId: int.parse(_ctrl('s_emp').text),
                  fecha: _ctrl('s_fecha').text,
                  hora: _ctrl('s_hora').text,
                  tipo: _ctrl('s_tipo').text,
                ));
                _editAsistenciaId = null;
              }
            });
          }),
          if (_editAsistenciaId != null)
            _btn('Cancelar', () => setState(() => _editAsistenciaId = null)),
        ],
      ),
      _listHeader('Registros (${_asistencias.length})'),
      ..._asistencias.map((s) => ListTile(
            title: Text('#${s.id} ${s.tipo}'),
            subtitle: Text('practica:${s.practicaId} · ${s.fecha} ${s.hora}'),
            onTap: () => setState(() {
              _editAsistenciaId = s.id;
              _ctrl('s_prac', '${s.practicaId}');
              _ctrl('s_emp', '${s.empresaId}');
              _ctrl('s_fecha', s.fecha);
              _ctrl('s_hora', s.hora);
              _ctrl('s_tipo', s.tipo);
            }),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _run(() => _service.deleteAsistencia(s.id!)),
            ),
          )),
    ]);
  }

  Widget _scroll(List<Widget> children) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: children,
    );
  }

  String? _opt(String v) => v.trim().isEmpty ? null : v.trim();

  int? _optInt(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    return int.parse(t);
  }
}
