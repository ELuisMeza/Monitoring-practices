# Following Practices

App móvil Flutter para seguimiento de prácticas preprofesionales.  
Usa **SQLite** como base de datos local offline y una arquitectura **front / back** dentro de `lib/`.

---

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.12)
- Dart ^3.12
- Dispositivo/emulador o Windows desktop para ejecutar la app

---

## Comandos necesarios

### 1. Instalar dependencias

```bash
flutter pub get
```

### 2. Crear / actualizar la base de datos (obligatorio antes de usar la app)

Las migraciones **solo** se ejecutan con el script. La app **no** migra automáticamente al iniciar.

```bash
dart run bin/migrate.dart
```

Con ruta personalizada:

```bash
dart run bin/migrate.dart --path ./data/following_practices.db
```

Por defecto crea: `{proyecto}/data/following_practices.db`

### 3. Ejecutar la app

```bash
flutter run
```

En un dispositivo concreto:

```bash
flutter devices
flutter run -d <device_id>
```

### 4. Análisis estático

```bash
dart analyze lib
```

### 5. Tests

```bash
flutter test
```

---

## Base de datos


| Recurso | Ubicación |
|---------|-----------|
| Definición SQL de tablas | `lib/back/database/schema/initial_schema.dart` |
| Migraciones versionadas | `lib/back/database/migrations/` |
| Script de migración | `bin/migrate.dart` |

### Tablas

- `usuarios` — estudiantes, tutores, supervisores, coordinadores
- `empresas` — empresas con `qr_token` para asistencia
- `practicas` — vínculo estudiante ↔ empresa
- `actividades` — registro diario de actividades
- `observaciones` — comentarios de revisión
- `asistencias` — entradas/salidas por QR
- `schema_migrations` — control interno de migraciones aplicadas

### Ubicación del archivo `.db`

Regla unificada: `{directorio_base}/data/following_practices.db`

| Contexto | Ruta |
|----------|------|
| Script CLI (PC) | `proyecto/data/following_practices.db` |
| App en emulador/móvil | almacenamiento interno de la app + `data/following_practices.db` |
| App en desktop | carpeta de soporte de la app + `data/following_practices.db` |

### Ver la base de datos

Instalar [DB Browser for SQLite](https://sqlitebrowser.org/) y abrir el archivo `.db` generado.

---

## Estructura de carpetas

```
lib/
├── main.dart                         # Entrada: init BD + runApp
│
├── front/                            # Capa UI (Flutter)
│   ├── pages/                        # Pantallas completas
│   ├── components/                   # Widgets reutilizables
│   ├── services/                     # Puente front → back
│   ├── utils/                        # Helpers de UI
│   └── lib/                          # Config global (app, tema)
│       ├── app.dart
│       └── theme/
│
└── back/                             # Capa de datos y lógica
    ├── database/                     # Conexión SQLite + migraciones
    │   ├── database_api_client.dart  # Única conexión a la BD
    │   ├── database_factory.dart     # Singleton del cliente
    │   ├── database_path.dart        # Ruta BD (app)
    │   ├── database_path_cli.dart    # Ruta BD (script)
    │   ├── schema/
    │   └── migrations/
    ├── entities/                     # Tablas SQLite + CRUD
    ├── dtos/                         # Tipados de respuesta (no son tablas)
    ├── services/                     # Lógica de negocio
    └── validators/                   # Validación de datos del front

bin/
└── migrate.dart                      # Único comando de migración

data/
└── following_practices.db            # BD local (generada, no commitear)
```

---

## Flujo de una petición (front → back)

```
Page (front)
    ↓
Service (front/services)        ← valida entrada (InputValidator)
    ↓
Service (back/services)         ← lógica de negocio + validación
    ↓
Entity (back/entities)          ← CRUD + consultas SQLite
    ↓
EntityDatabase                  ← acceso SQLite
    ↓
DatabaseApiClient               ← conexión única
    ↓
SQLite
    ↓
DTO (back/dtos)                 ← respuesta tipada hacia el front (si aplica)
```

## Responsabilidad por capa

| Capa | Responsabilidad | ¿Accede a SQLite? |
|------|-----------------|-------------------|
| `front/pages` | UI, estado local (`setState`) | No |
| `front/services` | Puerta de entrada del front al back | No |
| `back/services` | Reglas, cálculos, validación | No (solo llama entities) |
| `back/entities` | Mapeo tablas + `create/read/update/delete` | Sí |
| `back/dtos` | Tipados de respuesta compuesta | No |
| `back/database` | Conexión y migraciones | Sí (solo conexión) |

---

## Entities: CRUD estándar

Cada entity en `back/entities/` expone:

| Método | Uso |
|--------|-----|
| `create()` | Insertar registro |
| `read(id)` | Buscar por id |
| `readAll(...)` | Listar con filtros (`where`, `whereArgs`, `orderBy`) |
| `update()` | Actualizar registro existente |
| `delete()` | Eliminar registro |

Mapeo SQLite ↔ Dart:

- `fromMap()` — fila de BD → objeto
- `toMap()` — objeto → columnas de BD

---

## Reglas para el equipo

1. **Front nunca importa** `back/entities` ni `back/database` directamente (excepto DTOs para tipado).
2. **Back nunca importa** `flutter/material.dart`.
3. **Solo entities** ejecutan SQL (vía `entity_database.dart`).
4. **Migraciones solo** con `dart run bin/migrate.dart`.
5. **Un service del front** por módulo funcional (auth, actividades, usuarios, etc.).
6. **Un service del back** con la lógica de negocio del mismo módulo.
7. **Nombres de archivo** en `snake_case`; clases en `PascalCase`.

---

## Agregar una nueva migración

1. Crear `lib/back/database/migrations/migration_00X_nombre.dart`
2. Registrarla en `migration_runner.dart`
3. Incrementar `dbVersion` en `database_constants.dart`
4. Ejecutar: `dart run bin/migrate.dart`

---

## Recursos Flutter

- [Documentación Flutter](https://docs.flutter.dev/)
- [sqflite](https://pub.dev/packages/sqflite)
