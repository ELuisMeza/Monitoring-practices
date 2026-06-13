import 'package:flutter_test/flutter_test.dart';
import 'package:following_practices/back/services/asistencia_service.dart';
import '../helpers/test_database.dart';

void main() {
  setUp(() async => setupTestDatabase());
  tearDown(() async => tearDownTestDatabase());

  group('AsistenciaService', () {
    test('registra entrada con QR válido', () async {
      final service = AsistenciaService();
      final asistencia = await service.registrarPorQr(
        estudianteId: 1,
        qrToken: 'DEMO-QR-TECH-001',
      );
      expect(asistencia.tipo, 'entrada');
    });

    test('registra salida después de entrada', () async {
      final service = AsistenciaService();
      await service.registrarPorQr(estudianteId: 1, qrToken: 'DEMO-QR-TECH-001');
      final salida = await service.registrarPorQr(
        estudianteId: 1,
        qrToken: 'DEMO-QR-TECH-001',
      );
      expect(salida.tipo, 'salida');
    });

    test('rechaza QR de otra empresa', () async {
      final service = AsistenciaService();
      expect(
        () => service.registrarPorQr(estudianteId: 1, qrToken: 'OTRO-TOKEN'),
        throwsA(isA<StateError>()),
      );
    });

    test('rechaza tercer registro en el mismo día', () async {
      final service = AsistenciaService();
      await service.registrarPorQr(estudianteId: 1, qrToken: 'DEMO-QR-TECH-001');
      await service.registrarPorQr(estudianteId: 1, qrToken: 'DEMO-QR-TECH-001');
      expect(
        () => service.registrarPorQr(estudianteId: 1, qrToken: 'DEMO-QR-TECH-001'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
