/// Constantes globales de la base de datos SQLite.
class DatabaseConstants {
  DatabaseConstants._();

  /// Carpeta relativa donde vive la única BD de cada entorno.
  static const String storageDir = 'data';

  static const String dbName = 'following_practices.db';
  static const int dbVersion = 5;

  static const String tableSchemaMigrations = 'schema_migrations';
}
