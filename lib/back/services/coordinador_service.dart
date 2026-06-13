import 'package:following_practices/back/dtos/dashboard_coordinador_dto.dart';
import 'package:following_practices/back/dtos/empresa_list_item_dto.dart';
import 'package:following_practices/back/dtos/practica_admin_item_dto.dart';
import 'package:following_practices/back/dtos/usuario_list_item_dto.dart';
import 'package:following_practices/back/entities/actividad.dart';
import 'package:following_practices/back/entities/empresa.dart';
import 'package:following_practices/back/entities/practica.dart';
import 'package:following_practices/back/entities/usuario.dart';
import 'package:following_practices/back/utils/password_hash.dart';
import 'package:following_practices/back/validators/input_validator.dart';

/// Métricas, listados y CRUD administrativo para el coordinador de prácticas.
class CoordinadorService {
  // --- Dashboard existente ---

  Future<DashboardCoordinadorDto> obtenerDashboard() async {
    final practicas = await Practica.readAllActivas();
    var totalHoras = 0.0;
    var pendientes = 0;
    final items = <PracticaDashboardItemDto>[];

    for (final practica in practicas) {
      if (practica.id == null) continue;

      final horas = await Actividad.sumHorasByPracticaId(practica.id!);
      totalHoras += horas;

      final actividades = await Actividad.readPendientesByPracticaIds([practica.id!]);
      pendientes += actividades.length;

      final estudiante = await Usuario.read(practica.estudianteId);
      final empresa = await Empresa.read(practica.empresaId);

      items.add(
        PracticaDashboardItemDto(
          practicaId: practica.id!,
          estudianteNombre: estudiante?.nombre ?? '—',
          empresaNombre: empresa?.nombre ?? '—',
          horasAcumuladas: horas,
          horasRequeridas: practica.horasRequeridas,
          estado: practica.estado,
          actividadesPendientes: actividades.length,
        ),
      );
    }

    return DashboardCoordinadorDto(
      practicasActivas: practicas.length,
      totalEstudiantes: practicas.length,
      totalHorasAcumuladas: totalHoras,
      actividadesPendientes: pendientes,
      practicas: items,
    );
  }

  Future<List<PracticaDashboardItemDto>> listarPracticas({
    String? estadoFiltro,
    int? empresaId,
  }) async {
    var practicas = await Practica.readAll(orderBy: 'fecha_inicio DESC');

    if (estadoFiltro != null && estadoFiltro.isNotEmpty) {
      practicas = practicas.where((p) => p.estado == estadoFiltro).toList();
    }
    if (empresaId != null) {
      practicas = practicas.where((p) => p.empresaId == empresaId).toList();
    }

    return _mapPracticasDashboard(practicas);
  }

  // --- Usuarios CRUD ---

  Future<List<UsuarioListItemDto>> listarUsuarios({String? rolFiltro}) async {
    final usuarios = rolFiltro == null || rolFiltro.isEmpty
        ? await Usuario.readAll(orderBy: 'nombre ASC')
        : await Usuario.readByRol(rolFiltro);

    final result = <UsuarioListItemDto>[];
    for (final u in usuarios) {
      if (u.id == null) continue;
      String? empresaNombre;
      if (u.empresaId != null) {
        final emp = await Empresa.read(u.empresaId!);
        empresaNombre = emp?.nombre;
      }
      result.add(
        UsuarioListItemDto(
          id: u.id!,
          nombre: u.nombre,
          email: u.email,
          rol: u.rol,
          telefono: u.telefono,
          empresaId: u.empresaId,
          empresaNombre: empresaNombre,
        ),
      );
    }
    return result;
  }

  Future<Usuario> crearUsuario({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    String? telefono,
    int? empresaId,
  }) async {
    _validarUsuarioInput(nombre: nombre, email: email, password: password, rol: rol);
    await _validarEmpresaSupervisor(rol: rol, empresaId: empresaId);

    if (await Usuario.readByEmail(email.trim().toLowerCase()) != null) {
      throw StateError('Ya existe un usuario con ese email.');
    }

    return Usuario(
      nombre: nombre.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: PasswordHash.hash(password),
      rol: rol,
      telefono: telefono?.trim(),
      empresaId: rol == Usuario.rolSupervisor ? empresaId : null,
    ).create();
  }

  Future<Usuario> actualizarUsuario({
    required int id,
    required String nombre,
    required String email,
    required String rol,
    String? telefono,
    int? empresaId,
    String? nuevaPassword,
  }) async {
    final existente = await Usuario.read(id);
    if (existente == null) throw StateError('Usuario no encontrado.');

    _validarUsuarioInput(
      nombre: nombre,
      email: email,
      password: nuevaPassword ?? '123456',
      rol: rol,
      passwordRequerida: nuevaPassword != null,
    );
    await _validarEmpresaSupervisor(rol: rol, empresaId: empresaId);

    final otro = await Usuario.readByEmail(email.trim().toLowerCase());
    if (otro != null && otro.id != id) {
      throw StateError('Ya existe otro usuario con ese email.');
    }

    final actualizado = Usuario(
      id: id,
      nombre: nombre.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: nuevaPassword != null && nuevaPassword.isNotEmpty
          ? PasswordHash.hash(nuevaPassword)
          : existente.passwordHash,
      rol: rol,
      telefono: telefono?.trim(),
      empresaId: rol == Usuario.rolSupervisor ? empresaId : null,
      createdAt: existente.createdAt,
    );
    await actualizado.update();
    return actualizado;
  }

  Future<void> eliminarUsuario(int id) async {
    final usuario = await Usuario.read(id);
    if (usuario == null) throw StateError('Usuario no encontrado.');

    final practicasEst = await Practica.readAll(
      where: 'estudiante_id = ? OR tutor_id = ? OR supervisor_id = ?',
      whereArgs: [id, id, id],
      limit: 1,
    );
    if (practicasEst.isNotEmpty) {
      throw StateError('No se puede eliminar: el usuario está en una práctica.');
    }
    await usuario.delete();
  }

  // --- Empresas CRUD ---

  Future<List<EmpresaListItemDto>> listarEmpresas() async {
    final empresas = await Empresa.readAll(orderBy: 'nombre ASC');
    final result = <EmpresaListItemDto>[];

    for (final e in empresas) {
      if (e.id == null) continue;
      final activas = await Practica.readAll(
        where: 'empresa_id = ? AND estado = ?',
        whereArgs: [e.id, Practica.estadoActiva],
      );
      result.add(
        EmpresaListItemDto(
          id: e.id!,
          nombre: e.nombre,
          ruc: e.ruc,
          direccion: e.direccion,
          qrToken: e.qrToken,
          practicasActivas: activas.length,
        ),
      );
    }
    return result;
  }

  Future<Empresa> crearEmpresa({
    required String nombre,
    required String qrToken,
    String? ruc,
    String? direccion,
    String? contactoNombre,
    String? contactoEmail,
  }) async {
    final nombreError = InputValidator.requiredText(nombre, label: 'Nombre');
    if (nombreError != null) throw ArgumentError(nombreError);
    if (qrToken.trim().isEmpty) throw ArgumentError('QR token obligatorio.');

    final dup = await Empresa.readByQrToken(qrToken.trim());
    if (dup != null) throw StateError('Ya existe una empresa con ese QR token.');

    return Empresa(
      nombre: nombre.trim(),
      qrToken: qrToken.trim(),
      ruc: ruc?.trim(),
      direccion: direccion?.trim(),
      contactoNombre: contactoNombre?.trim(),
      contactoEmail: contactoEmail?.trim(),
    ).create();
  }

  Future<Empresa> actualizarEmpresa({
    required int id,
    required String nombre,
    required String qrToken,
    String? ruc,
    String? direccion,
    String? contactoNombre,
    String? contactoEmail,
  }) async {
    final existente = await Empresa.read(id);
    if (existente == null) throw StateError('Empresa no encontrada.');

    final dup = await Empresa.readByQrToken(qrToken.trim());
    if (dup != null && dup.id != id) {
      throw StateError('Ya existe otra empresa con ese QR token.');
    }

    final actualizada = Empresa(
      id: id,
      nombre: nombre.trim(),
      qrToken: qrToken.trim(),
      ruc: ruc?.trim(),
      direccion: direccion?.trim(),
      contactoNombre: contactoNombre?.trim(),
      contactoEmail: contactoEmail?.trim(),
      createdAt: existente.createdAt,
    );
    await actualizada.update();
    return actualizada;
  }

  Future<void> eliminarEmpresa(int id) async {
    final practicas = await Practica.readAll(
      where: 'empresa_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (practicas.isNotEmpty) {
      throw StateError('No se puede eliminar: hay prácticas vinculadas.');
    }

    final supervisores = await Usuario.readAll(
      where: 'empresa_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (supervisores.isNotEmpty) {
      throw StateError('No se puede eliminar: hay supervisores vinculados.');
    }

    final empresa = await Empresa.read(id);
    if (empresa == null) throw StateError('Empresa no encontrada.');
    await empresa.delete();
  }

  // --- Prácticas CRUD ---

  Future<List<PracticaAdminItemDto>> listarPracticasAdmin({String? estadoFiltro}) async {
    var practicas = await Practica.readAll(orderBy: 'fecha_inicio DESC');
    if (estadoFiltro != null && estadoFiltro.isNotEmpty) {
      practicas = practicas.where((p) => p.estado == estadoFiltro).toList();
    }
    return _mapPracticasAdmin(practicas);
  }

  Future<Practica> crearPractica({
    required int estudianteId,
    required int empresaId,
    required int tutorId,
    required String fechaInicio,
    String? fechaFin,
    required int horasRequeridas,
    String estado = Practica.estadoActiva,
  }) async {
    await _validarPracticaInput(
      estudianteId: estudianteId,
      empresaId: empresaId,
      tutorId: tutorId,
      fechaInicio: fechaInicio,
      horasRequeridas: horasRequeridas,
      estado: estado,
    );

    if (estado == Practica.estadoActiva) {
      final activa = await Practica.readActivaByEstudianteId(estudianteId);
      if (activa != null) {
        throw StateError('El estudiante ya tiene una práctica activa.');
      }
    }

    return Practica(
      estudianteId: estudianteId,
      empresaId: empresaId,
      tutorId: tutorId,
      fechaInicio: fechaInicio.trim(),
      fechaFin: fechaFin?.trim(),
      horasRequeridas: horasRequeridas,
      estado: estado,
    ).create();
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
  }) async {
    final existente = await Practica.read(id);
    if (existente == null) throw StateError('Práctica no encontrada.');

    await _validarPracticaInput(
      estudianteId: estudianteId,
      empresaId: empresaId,
      tutorId: tutorId,
      fechaInicio: fechaInicio,
      horasRequeridas: horasRequeridas,
      estado: estado,
    );

    if (estado == Practica.estadoActiva) {
      final activa = await Practica.readActivaByEstudianteId(estudianteId);
      if (activa != null && activa.id != id) {
        throw StateError('El estudiante ya tiene otra práctica activa.');
      }
    }

    final actualizada = Practica(
      id: id,
      estudianteId: estudianteId,
      empresaId: empresaId,
      tutorId: tutorId,
      supervisorId: existente.supervisorId,
      fechaInicio: fechaInicio.trim(),
      fechaFin: fechaFin?.trim(),
      horasRequeridas: horasRequeridas,
      estado: estado,
      createdAt: existente.createdAt,
    );
    await actualizada.update();
    return actualizada;
  }

  Future<void> eliminarPractica(int id) async {
    final actividades = await Actividad.readAll(
      where: 'practica_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (actividades.isNotEmpty) {
      throw StateError('No se puede eliminar: la práctica tiene actividades.');
    }

    final practica = await Practica.read(id);
    if (practica == null) throw StateError('Práctica no encontrada.');
    await practica.delete();
  }

  // --- Helpers ---

  Future<List<PracticaDashboardItemDto>> _mapPracticasDashboard(
    List<Practica> practicas,
  ) async {
    final items = <PracticaDashboardItemDto>[];
    for (final practica in practicas) {
      if (practica.id == null) continue;
      final horas = await Actividad.sumHorasByPracticaId(practica.id!);
      final pendientes = await Actividad.readPendientesByPracticaIds([practica.id!]);
      final estudiante = await Usuario.read(practica.estudianteId);
      final empresa = await Empresa.read(practica.empresaId);

      items.add(
        PracticaDashboardItemDto(
          practicaId: practica.id!,
          estudianteNombre: estudiante?.nombre ?? '—',
          empresaNombre: empresa?.nombre ?? '—',
          horasAcumuladas: horas,
          horasRequeridas: practica.horasRequeridas,
          estado: practica.estado,
          actividadesPendientes: pendientes.length,
        ),
      );
    }
    return items;
  }

  Future<List<PracticaAdminItemDto>> _mapPracticasAdmin(List<Practica> practicas) async {
    final items = <PracticaAdminItemDto>[];
    for (final p in practicas) {
      if (p.id == null) continue;
      final estudiante = await Usuario.read(p.estudianteId);
      final empresa = await Empresa.read(p.empresaId);
      String? tutorNombre;
      String? supervisorNombre;
      if (p.tutorId != null) {
        tutorNombre = (await Usuario.read(p.tutorId!))?.nombre;
      }
      if (p.supervisorId != null) {
        supervisorNombre = (await Usuario.read(p.supervisorId!))?.nombre;
      }
      items.add(
        PracticaAdminItemDto(
          id: p.id!,
          estudianteId: p.estudianteId,
          estudianteNombre: estudiante?.nombre ?? '—',
          empresaId: p.empresaId,
          empresaNombre: empresa?.nombre ?? '—',
          tutorId: p.tutorId,
          tutorNombre: tutorNombre,
          supervisorId: p.supervisorId,
          supervisorNombre: supervisorNombre,
          fechaInicio: p.fechaInicio,
          fechaFin: p.fechaFin,
          horasRequeridas: p.horasRequeridas,
          estado: p.estado,
        ),
      );
    }
    return items;
  }

  void _validarUsuarioInput({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    bool passwordRequerida = true,
  }) {
    final nombreError = InputValidator.requiredText(nombre, label: 'Nombre');
    if (nombreError != null) throw ArgumentError(nombreError);
    final emailError = InputValidator.email(email);
    if (emailError != null) throw ArgumentError(emailError);
    if (passwordRequerida) {
      final passError = InputValidator.password(password);
      if (passError != null) throw ArgumentError(passError);
    }
    final rolError = InputValidator.rol(rol);
    if (rolError != null) throw ArgumentError(rolError);
  }

  Future<void> _validarEmpresaSupervisor({
    required String rol,
    int? empresaId,
  }) async {
    if (rol == Usuario.rolSupervisor) {
      if (empresaId == null) {
        throw ArgumentError('El supervisor debe tener una empresa asignada.');
      }
      final empresa = await Empresa.read(empresaId);
      if (empresa == null) throw StateError('Empresa no encontrada.');
    }
  }

  Future<void> _validarPracticaInput({
    required int estudianteId,
    required int empresaId,
    required int tutorId,
    required String fechaInicio,
    required int horasRequeridas,
    required String estado,
  }) async {
    final fechaError = InputValidator.fechaIso(fechaInicio);
    if (fechaError != null) throw ArgumentError(fechaError);
    if (horasRequeridas <= 0) throw ArgumentError('Horas requeridas inválidas.');

    final estudiante = await Usuario.read(estudianteId);
    if (estudiante == null || estudiante.rol != Usuario.rolEstudiante) {
      throw StateError('Estudiante inválido.');
    }

    final empresa = await Empresa.read(empresaId);
    if (empresa == null) throw StateError('Empresa no encontrada.');

    final tutor = await Usuario.read(tutorId);
    if (tutor == null || tutor.rol != Usuario.rolTutor) {
      throw StateError('Tutor inválido.');
    }
  }
}
