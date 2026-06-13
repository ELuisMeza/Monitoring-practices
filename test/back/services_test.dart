import 'package:flutter_test/flutter_test.dart';
import 'package:following_practices/back/services/actividad_service.dart';
import 'package:following_practices/back/services/auth_service.dart';
import 'package:following_practices/back/validators/input_validator.dart';
import '../helpers/test_database.dart';

void main() {
  setUp(() async => setupTestDatabase());
  tearDown(() async => tearDownTestDatabase());

  group('AuthService', () {
    test('login exitoso con usuario demo', () async {
      final auth = AuthService();
      final sesion = await auth.login('estudiante@demo.com', '123456');
      expect(sesion.rol, 'estudiante');
      expect(sesion.email, 'estudiante@demo.com');
    });

    test('login falla con credenciales inválidas', () async {
      final auth = AuthService();
      expect(
        () => auth.login('estudiante@demo.com', '000000'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('ActividadService', () {
    test('registrar actividad para estudiante demo', () async {
      final actividadService = ActividadService();
      final actividad = await actividadService.registrarActividad(
        estudianteId: 1,
        fecha: InputValidator.formatoFecha(DateTime.now()),
        descripcion: 'Desarrollo de módulo login',
        horasCumplidas: 4,
      );
      expect(actividad.estado, 'registrado');
      expect(actividad.horasCumplidas, 4);
    });

    test('calcular horas última semana', () async {
      final actividadService = ActividadService();
      await actividadService.registrarActividad(
        estudianteId: 1,
        fecha: InputValidator.formatoFecha(DateTime.now()),
        descripcion: 'Prueba',
        horasCumplidas: 3,
      );
      final resumen = await actividadService.calcularHorasUltimaSemana(1);
      expect(resumen, isNotNull);
      expect(resumen!.totalHoras, 3);
    });

    test('tutor puede revisar actividad', () async {
      final actividadService = ActividadService();
      final actividad = await actividadService.registrarActividad(
        estudianteId: 1,
        fecha: InputValidator.formatoFecha(DateTime.now()),
        descripcion: 'Para revisión',
        horasCumplidas: 2,
      );

      await actividadService.revisarActividad(
        actividadId: actividad.id!,
        revisorId: 2,
        nuevoEstado: 'aprobado',
        observacionTexto: 'Buen trabajo',
      );

      final detalle = await actividadService.obtenerDetalle(actividad.id!);
      expect(detalle!.estado, 'aprobado');
      expect(detalle.observaciones.length, 1);
    });
  });
}
