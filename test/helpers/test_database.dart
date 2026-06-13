import 'package:following_practices/back/database/database_factory.dart';
import 'package:following_practices/back/database/migrations/migration_runner.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide DatabaseFactory;

Future<void> setupTestDatabase() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  await DatabaseFactory.reset();
  await DatabaseFactory.apiClient.initialize(databasePath: ':memory:');
  await MigrationRunner.run(DatabaseFactory.apiClient.database);
}

Future<void> tearDownTestDatabase() async {
  await DatabaseFactory.reset();
}
