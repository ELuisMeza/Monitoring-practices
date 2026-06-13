import 'package:flutter_test/flutter_test.dart';
import 'package:following_practices/back/entities/empresa.dart';
import 'package:following_practices/back/entities/practica.dart';
import 'package:following_practices/back/entities/usuario.dart';
import 'package:following_practices/back/services/actividad_service.dart';
import 'package:following_practices/back/services/auth_service.dart';
import 'package:following_practices/back/services/coordinador_service.dart';
import 'package:following_practices/back/services/practica_service.dart';
import 'package:following_practices/back/validators/input_validator.dart';
import '../helpers/test_database.dart';

void main() {
  setUp(() async => setupTestDatabase());
  tearDown(() async => tearDownTestDatabase());

  group('Supervisor por empresa', () {
    test('supervisor demo tiene empresa_id y ve prácticas de su empresa', () async {
      final supervisor = await Usuario.readByEmail('supervisor@demo.com');
      expect(supervisor, isNotNull);
      expect(supervisor!.empresaId, isNotNull);

      final practicaService = PracticaService();
      final practicas = await practicaService.listarPracticasPorSupervisor(supervisor.id!);
      expect(practicas, isNotEmpty);
      expect(practicas.every((p) => p.empresaId == supervisor.empresaId), isTrue);

      final alcance = await practicaService.obtenerAlcanceSupervisor(supervisor.id!);
      expect(alcance.empresaNombre, isNotNull);
      expect(alcance.practicantesActivos, greaterThan(0));
    });

    test('pendientes del supervisor se filtran por empresa', () async {
      final auth = AuthService();
      await auth.login('estudiante@demo.com', '123456');
      final estudiante = await Usuario.readByEmail('estudiante@demo.com');
      final supervisor = await Usuario.readByEmail('supervisor@demo.com');
      expect(estudiante, isNotNull);
      expect(supervisor, isNotNull);

      final actividadService = ActividadService();
      await actividadService.registrarActividad(
        estudianteId: estudiante!.id!,
        fecha: InputValidator.formatoFecha(DateTime.now()),
        descripcion: 'Actividad para supervisor por empresa',
        horasCumplidas: 2,
      );

      final pendientes = await actividadService.listarPendientesPorSupervisor(supervisor!.id!);
      expect(pendientes, isNotEmpty);
      expect(
        pendientes.any((a) => a.descripcion == 'Actividad para supervisor por empresa'),
        isTrue,
      );
    });
  });

  group('Coordinador CRUD', () {
    test('crear supervisor requiere empresa', () async {
      final coordinador = CoordinadorService();
      expect(
        () => coordinador.crearUsuario(
          nombre: 'Sup sin empresa',
          email: 'sup.sin.emp@demo.com',
          password: '123456',
          rol: Usuario.rolSupervisor,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('CRUD usuario supervisor con empresa', () async {
      final coordinador = CoordinadorService();
      final empresas = await coordinador.listarEmpresas();
      expect(empresas, isNotEmpty);

      final creado = await coordinador.crearUsuario(
        nombre: 'Supervisor Test',
        email: 'supervisor.test@demo.com',
        password: '123456',
        rol: Usuario.rolSupervisor,
        empresaId: empresas.first.id,
      );
      expect(creado.empresaId, empresas.first.id);

      final actualizado = await coordinador.actualizarUsuario(
        id: creado.id!,
        nombre: 'Supervisor Test Editado',
        email: 'supervisor.test@demo.com',
        rol: Usuario.rolSupervisor,
        empresaId: empresas.first.id,
      );
      expect(actualizado.nombre, 'Supervisor Test Editado');

      await coordinador.eliminarUsuario(creado.id!);
      expect(await Usuario.read(creado.id!), isNull);
    });

    test('CRUD empresa', () async {
      final coordinador = CoordinadorService();
      final empresa = await coordinador.crearEmpresa(
        nombre: 'Empresa Test CRUD',
        qrToken: 'QR-TEST-CRUD-001',
      );
      expect(empresa.id, isNotNull);

      final actualizada = await coordinador.actualizarEmpresa(
        id: empresa.id!,
        nombre: 'Empresa Test Editada',
        qrToken: 'QR-TEST-CRUD-001',
      );
      expect(actualizada.nombre, 'Empresa Test Editada');

      await coordinador.eliminarEmpresa(empresa.id!);
      expect(await Empresa.read(empresa.id!), isNull);
    });

    test('práctica requiere tutor', () async {
      final coordinador = CoordinadorService();
      final estudiante = await Usuario.readByEmail('estudiante@demo.com');
      final empresas = await coordinador.listarEmpresas();
      expect(estudiante, isNotNull);

      expect(
        () => coordinador.crearPractica(
          estudianteId: estudiante!.id!,
          empresaId: empresas.first.id,
          tutorId: 99999,
          fechaInicio: '2026-02-01',
          horasRequeridas: 120,
          estado: Practica.estadoSuspendida,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('crear y eliminar práctica admin', () async {
      final coordinador = CoordinadorService();
      final estudiante = await Usuario.readByEmail('estudiante@demo.com');
      final tutor = await Usuario.readByEmail('tutor@demo.com');
      final empresas = await coordinador.listarEmpresas();
      expect(estudiante, isNotNull);
      expect(tutor, isNotNull);

      final practica = await coordinador.crearPractica(
        estudianteId: estudiante!.id!,
        empresaId: empresas.first.id,
        tutorId: tutor!.id!,
        fechaInicio: '2026-03-01',
        horasRequeridas: 80,
        estado: Practica.estadoSuspendida,
      );
      expect(practica.id, isNotNull);

      final lista = await coordinador.listarPracticasAdmin(estadoFiltro: Practica.estadoSuspendida);
      expect(lista.any((p) => p.id == practica.id), isTrue);

      await coordinador.eliminarPractica(practica.id!);
      expect(await Practica.read(practica.id!), isNull);
    });
  });
}
