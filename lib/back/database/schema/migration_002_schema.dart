/// DDL adicional: alertas e historial de estados.
class Migration002Schema {
  Migration002Schema._();

  static const String createAlertas = '''
CREATE TABLE IF NOT EXISTS alertas (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id  INTEGER NOT NULL REFERENCES usuarios(id),
    tipo        TEXT    NOT NULL
                         CHECK(
                           tipo IN (
                             'horas_bajas',
                             'pendientes_revision',
                             'practica_por_vencer'
                           )
                         ),
    titulo      TEXT    NOT NULL,
    mensaje     TEXT    NOT NULL,
    leida       INTEGER NOT NULL DEFAULT 0,
    created_at  TEXT    DEFAULT (datetime('now'))
);
''';

  static const String createHistorialEstados = '''
CREATE TABLE IF NOT EXISTS historial_estados (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    actividad_id    INTEGER NOT NULL REFERENCES actividades(id),
    usuario_id      INTEGER NOT NULL REFERENCES usuarios(id),
    estado_anterior TEXT,
    estado_nuevo    TEXT NOT NULL,
    created_at      TEXT DEFAULT (datetime('now'))
);
''';

  static const List<String> statements = [
    createAlertas,
    createHistorialEstados,
  ];
}