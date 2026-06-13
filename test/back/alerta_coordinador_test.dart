import 'package:flutter_test/flutter_test.dart';
import 'package:following_practices/back/services/alerta_service.dart';
import 'package:following_practices/back/services/coordinador_service.dart';
import '../helpers/test_database.dart';

void main() {
  setUp(() async => setupTestDatabase());
  tearDown(() async => tearDownTestDatabase());

  test('coordinador obtiene dashboard con práctica demo', () async {
    final service = CoordinadorService();
    final dashboard = await service.obtenerDashboard();
    expect(dashboard.practicasActivas, 1);
    expect(dashboard.practicas.length, 1);
  });

  test('alerta de horas bajas para estudiante sin actividades', () async {
    final service = AlertaService();
    await service.evaluarAlertasEstudiante(1);
    final alertas = await service.listarPorUsuario(1);
    expect(alertas.any((a) => a.tipo == 'horas_bajas'), isTrue);
  });
}
