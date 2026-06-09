import 'package:flutter_test/flutter_test.dart';
import 'package:following_practices/back/database/database_factory.dart';
import 'package:following_practices/back/database/migrations/migration_runner.dart';
import 'package:following_practices/front/lib/app.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide DatabaseFactory;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseFactory.reset();
    await DatabaseFactory.apiClient.initialize(databasePath: ':memory:');
    await MigrationRunner.run(DatabaseFactory.apiClient.database);
  });

  tearDown(() async {
    await DatabaseFactory.reset();
  });

  testWidgets('muestra la pantalla principal', (WidgetTester tester) async {
    await tester.pumpWidget(const FollowingPracticesApp());

    expect(find.text('Seguimiento de Prácticas'), findsOneWidget);

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();

    expect(find.text('Sin práctica activa.'), findsOneWidget);
  });
}
