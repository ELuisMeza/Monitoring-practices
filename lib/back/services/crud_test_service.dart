import 'package:following_practices/back/database/database_factory.dart';
import 'package:following_practices/back/database/database_path.dart';
import 'package:following_practices/back/database/migrations/migration_runner.dart';
import 'package:following_practices/back/entities/actividad.dart';
import 'package:following_practices/back/entities/asistencia.dart';
import 'package:following_practices/back/entities/empresa.dart';
import 'package:following_practices/back/entities/observacion.dart';
import 'package:following_practices/back/entities/practica.dart';
import 'package:following_practices/back/entities/usuario.dart';

/// CRUD de prueba para todas las tablas del dominio.
/// Solo para verificar conexión SQLite; no usar en producción.
class CrudTestService {
  Future<String> databasePath() => DatabasePath.resolve();

  Future<List<int>> ensureSchema() {
    return MigrationRunner.run(DatabaseFactory.apiClient.database);
  }

  // --- usuarios ---

  Future<List<Usuario>> listUsuarios() =>
      Usuario.readAll(orderBy: 'id DESC');

  Future<Usuario> createUsuario({
    required String nombre,
    required String email,
    required String passwordHash,
    required String rol,
    String? telefono,
  }) {
    return Usuario(
      nombre: nombre,
      email: email,
      passwordHash: passwordHash,
      rol: rol,
      telefono: telefono,
    ).create();
  }

  Future<void> updateUsuario(Usuario usuario) => usuario.update();

  Future<void> deleteUsuario(int id) async {
    final item = await Usuario.read(id);
    if (item != null) await item.delete();
  }

  // --- empresas ---

  Future<List<Empresa>> listEmpresas() =>
      Empresa.readAll(orderBy: 'id DESC');

  Future<Empresa> createEmpresa({
    required String nombre,
    required String qrToken,
    String? ruc,
    String? direccion,
    String? contactoNombre,
    String? contactoEmail,
  }) {
    return Empresa(
      nombre: nombre,
      qrToken: qrToken,
      ruc: ruc,
      direccion: direccion,
      contactoNombre: contactoNombre,
      contactoEmail: contactoEmail,
    ).create();
  }

  Future<void> updateEmpresa(Empresa empresa) => empresa.update();

  Future<void> deleteEmpresa(int id) async {
    final item = await Empresa.read(id);
    if (item != null) await item.delete();
  }

  // --- practicas ---

  Future<List<Practica>> listPracticas() =>
      Practica.readAll(orderBy: 'id DESC');

  Future<Practica> createPractica({
    required int estudianteId,
    required int empresaId,
    required String fechaInicio,
    required int horasRequeridas,
    required String estado,
    int? tutorId,
    int? supervisorId,
    String? fechaFin,
  }) {
    return Practica(
      estudianteId: estudianteId,
      empresaId: empresaId,
      tutorId: tutorId,
      supervisorId: supervisorId,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      horasRequeridas: horasRequeridas,
      estado: estado,
    ).create();
  }

  Future<void> updatePractica(Practica practica) => practica.update();

  Future<void> deletePractica(int id) async {
    final item = await Practica.read(id);
    if (item != null) await item.delete();
  }

  // --- actividades ---

  Future<List<Actividad>> listActividades() =>
      Actividad.readAll(orderBy: 'id DESC');

  Future<Actividad> createActividad({
    required int practicaId,
    required String fecha,
    required String descripcion,
    required double horasCumplidas,
    required String estado,
    String? evidenciaUrl,
  }) {
    return Actividad(
      practicaId: practicaId,
      fecha: fecha,
      descripcion: descripcion,
      horasCumplidas: horasCumplidas,
      evidenciaUrl: evidenciaUrl,
      estado: estado,
    ).create();
  }

  Future<void> updateActividad(Actividad actividad) => actividad.update();

  Future<void> deleteActividad(int id) async {
    final item = await Actividad.read(id);
    if (item != null) await item.delete();
  }

  // --- observaciones ---

  Future<List<Observacion>> listObservaciones() =>
      Observacion.readAll(orderBy: 'id DESC');

  Future<Observacion> createObservacion({
    required int actividadId,
    required int usuarioId,
    required String texto,
  }) {
    return Observacion(
      actividadId: actividadId,
      usuarioId: usuarioId,
      texto: texto,
    ).create();
  }

  Future<void> updateObservacion(Observacion observacion) =>
      observacion.update();

  Future<void> deleteObservacion(int id) async {
    final item = await Observacion.read(id);
    if (item != null) await item.delete();
  }

  // --- asistencias ---

  Future<List<Asistencia>> listAsistencias() =>
      Asistencia.readAll(orderBy: 'id DESC');

  Future<Asistencia> createAsistencia({
    required int practicaId,
    required int empresaId,
    required String fecha,
    required String hora,
    required String tipo,
  }) {
    return Asistencia(
      practicaId: practicaId,
      empresaId: empresaId,
      fecha: fecha,
      hora: hora,
      tipo: tipo,
    ).create();
  }

  Future<void> updateAsistencia(Asistencia asistencia) => asistencia.update();

  Future<void> deleteAsistencia(int id) async {
    final item = await Asistencia.read(id);
    if (item != null) await item.delete();
  }
}
