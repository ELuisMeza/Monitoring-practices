/// Definición SQL del esquema inicial según arquitectura de BD (Caso 15).
class InitialSchema {
  InitialSchema._();

  static const String createSchemaMigrations = '''
CREATE TABLE IF NOT EXISTS schema_migrations (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    version    INTEGER NOT NULL UNIQUE,
    name       TEXT    NOT NULL,
    applied_at TEXT    DEFAULT (datetime('now'))
);
''';

  static const String createUsuarios = '''
CREATE TABLE IF NOT EXISTS usuarios (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre        TEXT    NOT NULL,
    email         TEXT    UNIQUE NOT NULL,
    password_hash TEXT    NOT NULL,
    rol           TEXT    NOT NULL CHECK(rol IN ('estudiante','tutor','supervisor','coordinador')),
    telefono      TEXT,
    created_at    TEXT    DEFAULT (datetime('now'))
);
''';

  static const String createEmpresas = '''
CREATE TABLE IF NOT EXISTS empresas (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre          TEXT NOT NULL,
    ruc             TEXT UNIQUE,
    direccion       TEXT,
    contacto_nombre TEXT,
    contacto_email  TEXT,
    qr_token        TEXT UNIQUE NOT NULL,
    created_at      TEXT DEFAULT (datetime('now'))
);
''';

  static const String createPracticas = '''
CREATE TABLE IF NOT EXISTS practicas (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    estudiante_id    INTEGER NOT NULL REFERENCES usuarios(id),
    empresa_id       INTEGER NOT NULL REFERENCES empresas(id),
    tutor_id         INTEGER REFERENCES usuarios(id),
    supervisor_id    INTEGER REFERENCES usuarios(id),
    fecha_inicio     TEXT NOT NULL,
    fecha_fin        TEXT,
    horas_requeridas INTEGER NOT NULL DEFAULT 240,
    estado           TEXT DEFAULT 'activa'
                           CHECK(estado IN ('activa','completada','suspendida')),
    created_at       TEXT DEFAULT (datetime('now'))
);
''';

  static const String createActividades = '''
CREATE TABLE IF NOT EXISTS actividades (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    practica_id     INTEGER NOT NULL REFERENCES practicas(id),
    fecha           TEXT    NOT NULL,
    descripcion     TEXT    NOT NULL,
    horas_cumplidas REAL    NOT NULL CHECK(horas_cumplidas > 0),
    evidencia_url   TEXT,
    estado          TEXT DEFAULT 'registrado'
                          CHECK(estado IN ('registrado','observado','aprobado','rechazado')),
    created_at      TEXT DEFAULT (datetime('now'))
);
''';

  static const String createObservaciones = '''
CREATE TABLE IF NOT EXISTS observaciones (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    actividad_id INTEGER NOT NULL REFERENCES actividades(id),
    usuario_id   INTEGER NOT NULL REFERENCES usuarios(id),
    texto        TEXT    NOT NULL,
    created_at   TEXT    DEFAULT (datetime('now'))
);
''';

  static const String createAsistencias = '''
CREATE TABLE IF NOT EXISTS asistencias (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    practica_id INTEGER NOT NULL REFERENCES practicas(id),
    empresa_id  INTEGER NOT NULL REFERENCES empresas(id),
    fecha       TEXT    NOT NULL,
    hora        TEXT    NOT NULL,
    tipo        TEXT    NOT NULL CHECK(tipo IN ('entrada','salida')),
    created_at  TEXT    DEFAULT (datetime('now'))
);
''';

  /// Tablas del dominio en orden de dependencias de claves foráneas.
  static const List<String> domainStatements = [
    createUsuarios,
    createEmpresas,
    createPracticas,
    createActividades,
    createObservaciones,
    createAsistencias,
  ];
}
