import 'package:flutter_test/flutter_test.dart';
import 'package:following_practices/front/lib/app.dart';
import 'helpers/test_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async => setupTestDatabase());
  tearDown(() async => tearDownTestDatabase());

  testWidgets('muestra pantalla de login', (WidgetTester tester) async {
    await tester.pumpWidget(const FollowingPracticesApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Seguimiento de Prácticas'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Demo: estudiante@demo.com / 123456'), findsOneWidget);
  });
}
