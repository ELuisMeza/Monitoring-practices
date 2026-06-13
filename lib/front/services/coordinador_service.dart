import 'package:following_practices/back/dtos/dashboard_coordinador_dto.dart';
import 'package:following_practices/back/dtos/empresa_list_item_dto.dart';
import 'package:following_practices/back/dtos/practica_admin_item_dto.dart';
import 'package:following_practices/back/dtos/usuario_list_item_dto.dart';
import 'package:following_practices/back/entities/empresa.dart';
import 'package:following_practices/back/entities/practica.dart';
import 'package:following_practices/back/entities/usuario.dart';
import 'package:following_practices/front/lib/service_locator.dart';

class CoordinadorService {
  Future<DashboardCoordinadorDto> obtenerDashboard() {
    return ServiceLocator.coordinador.obtenerDashboard();
  }

  Future<List<PracticaDashboardItemDto>> listarPracticas({
    String? estadoFiltro,
    int? empresaId,
  }) {
    return ServiceLocator.coordinador.listarPracticas(
      estadoFiltro: estadoFiltro,
      empresaId: empresaId,
    );
  }

  Future<List<UsuarioListItemDto>> listarUsuarios({String? rolFiltro}) {
    return ServiceLocator.coordinador.listarUsuarios(rolFiltro: rolFiltro);
  }

  Future<Usuario> crearUsuario({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    String? telefono,
    int? empresaId,
  }) {
    return ServiceLocator.coordinador.crearUsuario(
      nombre: nombre,
      email: email,
      password: password,
      rol: rol,
      telefono: telefono,
      empresaId: empresaId,
    );
  }

  Future<Usuario> actualizarUsuario({
    required int id,
    required String nombre,
    required String email,
    required String rol,
    String? telefono,
    int? empresaId,
    String? nuevaPassword,
  }) {
    return ServiceLocator.coordinador.actualizarUsuario(
      id: id,
      nombre: nombre,
      email: email,
      rol: rol,
      telefono: telefono,
      empresaId: empresaId,
      nuevaPassword: nuevaPassword,
    );
  }

  Future<void> eliminarUsuario(int id) {
    return ServiceLocator.coordinador.eliminarUsuario(id);
  }

  Future<List<EmpresaListItemDto>> listarEmpresas() {
    return ServiceLocator.coordinador.listarEmpresas();
  }

  Future<Empresa> crearEmpresa({
    required String nombre,
    required String qrToken,
    String? ruc,
    String? direccion,
    String? contactoNombre,
    String? contactoEmail,
  }) {
    return ServiceLocator.coordinador.crearEmpresa(
      nombre: nombre,
      qrToken: qrToken,
      ruc: ruc,
      direccion: direccion,
      contactoNombre: contactoNombre,
      contactoEmail: contactoEmail,
    );
  }

  Future<Empresa> actualizarEmpresa({
    required int id,
    required String nombre,
    required String qrToken,
    String? ruc,
    String? direccion,
    String? contactoNombre,
    String? contactoEmail,
  }) {
    return ServiceLocator.coordinador.actualizarEmpresa(
      id: id,
      nombre: nombre,
      qrToken: qrToken,
      ruc: ruc,
      direccion: direccion,
      contactoNombre: contactoNombre,
      contactoEmail: contactoEmail,
    );
  }

  Future<void> eliminarEmpresa(int id) {
    return ServiceLocator.coordinador.eliminarEmpresa(id);
  }

  Future<List<PracticaAdminItemDto>> listarPracticasAdmin({String? estadoFiltro}) {
    return ServiceLocator.coordinador.listarPracticasAdmin(estadoFiltro: estadoFiltro);
  }

  Future<Practica> crearPractica({
    required int estudianteId,
    required int empresaId,
    required int tutorId,
    required String fechaInicio,
    String? fechaFin,
    required int horasRequeridas,
    String estado = Practica.estadoActiva,
  }) {
    return ServiceLocator.coordinador.crearPractica(
      estudianteId: estudianteId,
      empresaId: empresaId,
      tutorId: tutorId,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      horasRequeridas: horasRequeridas,
      estado: estado,
    );
  }

  Future<Practica> actualizarPractica({
    required int id,
    required int estudianteId,
    required int empresaId,
    required int tutorId,
    required String fechaInicio,
    String? fechaFin,
    required int horasRequeridas,
    required String estado,
  }) {
    return ServiceLocator.coordinador.actualizarPractica(
      id: id,
      estudianteId: estudianteId,
      empresaId: empresaId,
      tutorId: tutorId,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      horasRequeridas: horasRequeridas,
      estado: estado,
    );
  }

  Future<void> eliminarPractica(int id) {
    return ServiceLocator.coordinador.eliminarPractica(id);
  }

  Future<Empresa?> obtenerEmpresa(int id) {
    return Empresa.read(id);
  }
}
