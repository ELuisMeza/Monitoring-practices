import 'package:following_practices/back/entities/actividad.dart';
import 'package:following_practices/back/entities/asistencia.dart';
import 'package:following_practices/back/entities/empresa.dart';
import 'package:following_practices/back/entities/observacion.dart';
import 'package:following_practices/back/entities/practica.dart';
import 'package:following_practices/back/entities/usuario.dart';
import 'package:following_practices/back/services/crud_test_service.dart'
    as back;

/// Puente front → back para el CRUD de prueba.
class CrudTestService {
  CrudTestService({back.CrudTestService? service})
      : _service = service ?? back.CrudTestService();

  final back.CrudTestService _service;

  Future<String> databasePath() => _service.databasePath();

  Future<List<int>> ensureSchema() => _service.ensureSchema();

  Future<List<Usuario>> listUsuarios() => _service.listUsuarios();
  Future<Usuario> createUsuario({
    required String nombre,
    required String email,
    required String passwordHash,
    required String rol,
    String? telefono,
  }) =>
      _service.createUsuario(
        nombre: nombre,
        email: email,
        passwordHash: passwordHash,
        rol: rol,
        telefono: telefono,
      );
  Future<void> updateUsuario(Usuario u) => _service.updateUsuario(u);
  Future<void> deleteUsuario(int id) => _service.deleteUsuario(id);

  Future<List<Empresa>> listEmpresas() => _service.listEmpresas();
  Future<Empresa> createEmpresa({
    required String nombre,
    required String qrToken,
    String? ruc,
    String? direccion,
    String? contactoNombre,
    String? contactoEmail,
  }) =>
      _service.createEmpresa(
        nombre: nombre,
        qrToken: qrToken,
        ruc: ruc,
        direccion: direccion,
        contactoNombre: contactoNombre,
        contactoEmail: contactoEmail,
      );
  Future<void> updateEmpresa(Empresa e) => _service.updateEmpresa(e);
  Future<void> deleteEmpresa(int id) => _service.deleteEmpresa(id);

  Future<List<Practica>> listPracticas() => _service.listPracticas();
  Future<Practica> createPractica({
    required int estudianteId,
    required int empresaId,
    required String fechaInicio,
    required int horasRequeridas,
    required String estado,
    int? tutorId,
    int? supervisorId,
    String? fechaFin,
  }) =>
      _service.createPractica(
        estudianteId: estudianteId,
        empresaId: empresaId,
        fechaInicio: fechaInicio,
        horasRequeridas: horasRequeridas,
        estado: estado,
        tutorId: tutorId,
        supervisorId: supervisorId,
        fechaFin: fechaFin,
      );
  Future<void> updatePractica(Practica p) => _service.updatePractica(p);
  Future<void> deletePractica(int id) => _service.deletePractica(id);

  Future<List<Actividad>> listActividades() => _service.listActividades();
  Future<Actividad> createActividad({
    required int practicaId,
    required String fecha,
    required String descripcion,
    required double horasCumplidas,
    required String estado,
    String? evidenciaUrl,
  }) =>
      _service.createActividad(
        practicaId: practicaId,
        fecha: fecha,
        descripcion: descripcion,
        horasCumplidas: horasCumplidas,
        estado: estado,
        evidenciaUrl: evidenciaUrl,
      );
  Future<void> updateActividad(Actividad a) => _service.updateActividad(a);
  Future<void> deleteActividad(int id) => _service.deleteActividad(id);

  Future<List<Observacion>> listObservaciones() =>
      _service.listObservaciones();
  Future<Observacion> createObservacion({
    required int actividadId,
    required int usuarioId,
    required String texto,
  }) =>
      _service.createObservacion(
        actividadId: actividadId,
        usuarioId: usuarioId,
        texto: texto,
      );
  Future<void> updateObservacion(Observacion o) =>
      _service.updateObservacion(o);
  Future<void> deleteObservacion(int id) => _service.deleteObservacion(id);

  Future<List<Asistencia>> listAsistencias() => _service.listAsistencias();
  Future<Asistencia> createAsistencia({
    required int practicaId,
    required int empresaId,
    required String fecha,
    required String hora,
    required String tipo,
  }) =>
      _service.createAsistencia(
        practicaId: practicaId,
        empresaId: empresaId,
        fecha: fecha,
        hora: hora,
        tipo: tipo,
      );
  Future<void> updateAsistencia(Asistencia a) => _service.updateAsistencia(a);
  Future<void> deleteAsistencia(int id) => _service.deleteAsistencia(id);
}
