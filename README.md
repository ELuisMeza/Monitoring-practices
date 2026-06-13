# Following Practices

App móvil Flutter para seguimiento de prácticas preprofesionales.  
Usa **SQLite** como base de datos local offline y una arquitectura **front / back** dentro de `lib/`.

---

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.12)
- Dart ^3.12
- **Windows / Linux / macOS** para desarrollo desktop, o **Android Studio** + emulador
- [DB Browser for SQLite](https://sqlitebrowser.org/) (opcional, para inspeccionar la BD)
- PowerShell (Windows) para los scripts de sincronización del emulador

Verificar instalación:

```bash
flutter doctor
flutter devices
```

---

## Inicio rápido

### 1. Clonar e instalar dependencias

```bash
cd following_practices
flutter pub get
```

### 2. Crear la base de datos (obligatorio)

Las migraciones **solo** se ejecutan con el script CLI. La app **no** migra automáticamente al iniciar (excepto la pantalla de prueba CRUD en debug).

```bash
dart run bin/migrate.dart
```

Esto crea: `data/following_practices.db`

### 3. Levantar la app

Elige **una** de las dos opciones según dónde quieras probar:

#### Opción A — Windows desktop 

La app lee y escribe **directamente** `data/following_practices.db`. No hay sincronización.

```bash
flutter run -d windows
```

Ideal para: desarrollo rápido, DB Browser, y ver cambios al instante en el mismo archivo.

#### Opción B — Emulador Android (con sincronización automática)

El emulador usa su propio almacenamiento interno. Los scripts copian la BD del PC al emulador al iniciar, y la traen de vuelta al salir.

```powershell
# Windows PowerShell — desde la raíz del proyecto
.\bin\run_emulator.ps1
```

Con emulador concreto (si hay varios):

```powershell
flutter devices
.\bin\run_emulator.ps1 -Device emulator-5554
```

**Salir correctamente:** en la terminal de Flutter escribe `q` y Enter. El script guardará la BD en `data/following_practices.db`.

Si el pull automático falla (emulador apagado, DB Browser abierto):

```powershell
.\bin\sync_db_emulator.ps1 pull -Device emulator-5554
```

---

## Cómo funciona la base de datos

### Archivo canónico

Todos los devs deben usar **un solo archivo** en el repositorio local:

```
proyecto/data/following_practices.db
```

### Dónde escribe cada entorno

| Contexto | Archivo que usa | ¿Sync manual? |
|----------|-----------------|---------------|
| CLI (`migrate.dart`) | `data/following_practices.db` | No |
| App Windows / Linux / macOS | `data/following_practices.db` | No |
| Emulador Android (debug) | Almacenamiento interno de la app | Sí, vía scripts |

### Flujo en emulador Android

```
PC: data/following_practices.db
        │
        │  push (run_emulator.ps1 al iniciar)
        ▼
Emulador: /data/local/tmp/ → copia interna app_flutter/data/
        │
        │  app lee/escribe en carpeta interna (writable)
        ▼
        │  pull (run_emulator.ps1 al salir)
        ▼
PC: data/following_practices.db  (actualizado)
```

Scripts disponibles en `bin/`:

| Script | Uso |
|--------|-----|
| `migrate.dart` | Crear/actualizar esquema en el PC |
| `run_emulator.ps1` | Push + `flutter run` + pull automático |
| `sync_db_emulator.ps1 push` | Enviar BD del PC al emulador |
| `sync_db_emulator.ps1 pull` | Traer BD del emulador al PC |

Ejemplo manual (sin `run_emulator.ps1`):

```powershell
dart run bin/migrate.dart
.\bin\sync_db_emulator.ps1 push -Device emulator-5554
flutter run -d emulator-5554
# ... probar ...
.\bin\sync_db_emulator.ps1 pull -Device emulator-5554
```

### Inspeccionar la BD

1. Cierra DB Browser si está abierto.
2. Si usaste emulador, asegúrate de haber hecho pull (o salido con `q` desde `run_emulator.ps1`).
3. Abre `data/following_practices.db` en [DB Browser for SQLite](https://sqlitebrowser.org/).

```sql
SELECT * FROM usuarios;
```

---

## Pantalla de prueba CRUD (solo desarrollo)

Para verificar conexión SQLite y probar todas las tablas:

1. Levanta la app (Windows o emulador).
2. En la pantalla principal, pulsa el icono de **base de datos** (AppBar).
3. Usa las pestañas para crear/editar/eliminar registros.

Orden sugerido por claves foráneas: **Usuarios → Empresas → Prácticas → Actividades → Observaciones → Asistencias**.

La pantalla muestra la ruta de BD activa y aplica migraciones pendientes en debug.

Archivos:

- `lib/back/services/crud_test_service.dart`
- `lib/front/pages/crud_test_page.dart`

---

## Comandos de desarrollo

### Análisis estático

```bash
dart analyze lib
```

### Tests

```bash
flutter test
```

### Migración con ruta personalizada

```bash
dart run bin/migrate.dart --path ./data/following_practices.db
```

---

## Solución de problemas

| Problema | Solución |
|----------|----------|
| `device 'e' not found` | Actualiza scripts (`git pull`) o usa `-Device emulator-5554` |
| App atascada en logo Flutter | BD readonly; usa `run_emulator.ps1` (no `flutter run` solo) |
| Pull falla al salir | Cierra DB Browser, emulador encendido, ejecuta `sync_db_emulator.ps1 pull` |
| Varios emuladores | `flutter devices` + `run_emulator.ps1 -Device <id>` |
| `Sin práctica activa` en home | Normal si no hay práctica activa; usa CRUD para poblar datos |
| `no such table` | Ejecuta `dart run bin/migrate.dart` y vuelve a hacer push |

---

## Base de datos (referencia)


| Recurso | Ubicación |
|---------|-----------|
| Definición SQL de tablas | `lib/back/database/schema/initial_schema.dart` |
| Migraciones versionadas | `lib/back/database/migrations/` |
| Script de migración | `bin/migrate.dart` |
| Sync emulador | `bin/run_emulator.ps1`, `bin/sync_db_emulator.ps1` |

### Tablas

- `usuarios` — estudiantes, tutores, supervisores (`empresa_id`), coordinadores
- `empresas` — empresas con `qr_token` para asistencia
- `practicas` — vínculo estudiante ↔ empresa
- `actividades` — registro diario de actividades
- `observaciones` — comentarios de revisión
- `asistencias` — entradas/salidas por QR
- `schema_migrations` — control interno de migraciones aplicadas

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
    │   ├── database_path_core.dart   # Lógica compartida de rutas
    │   ├── database_sync.dart        # Import BD tmp → app (Android debug)
    │   ├── schema/
    │   └── migrations/
    ├── entities/                     # Tablas SQLite + CRUD
    ├── dtos/                         # Tipados de respuesta (no son tablas)
    ├── services/                     # Lógica de negocio
    └── validators/                   # Validación de datos del front

bin/
├── migrate.dart                      # Crear/actualizar esquema (CLI)
├── run_emulator.ps1                  # Levantar app en emulador + sync BD
└── sync_db_emulator.ps1              # Push/pull manual de la BD

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

## Alcance MVP y reglas de negocio

### Roles y permisos

| Rol | Puede hacer |
|-----|-------------|
| **Estudiante** | Registrar actividades, ver historial, escanear QR de asistencia, ver reporte semanal y progreso de horas. |
| **Tutor** | Revisar actividades de sus practicantes (`practicas.tutor_id`), observar/aprobar/rechazar con comentario. |
| **Supervisor** | Validar actividades de **todas las prácticas activas de su empresa** (`usuarios.empresa_id`), ver asistencias del día de esa empresa. |
| **Coordinador** | Dashboard global, listar prácticas y **CRUD completo** de usuarios, empresas y prácticas (asignaciones tutor/supervisor). |

### Estados de actividad

| Estado | Significado | Transiciones permitidas |
|--------|-------------|-------------------------|
| `registrado` | Creado por el estudiante | → `observado`, `aprobado`, `rechazado` |
| `observado` | Revisado con comentario, pendiente de decisión | → `aprobado`, `rechazado` |
| `aprobado` | Validado por tutor/supervisor | Final |
| `rechazado` | Rechazado con observación | Final |

Solo actividades en `registrado` pueden editarse o eliminarse por el estudiante.

### Reglas de asistencia QR

1. El QR contiene el `qr_token` de la empresa.
2. El estudiante debe tener práctica **activa** en esa empresa.
3. Secuencia del día: **entrada** → **salida** (no doble entrada ni salida sin entrada previa).
4. Una asistencia por tipo (`entrada`/`salida`) por día y práctica.

### Reglas de horas

- Cada actividad registra `horas_cumplidas` > 0.
- **Horas semanales**: suma de actividades en los últimos 7 días.
- **Horas acumuladas**: suma total de actividades de la práctica activa vs `horas_requeridas`.

### Criterios de aceptación MVP

| Flujo | Criterio |
|-------|----------|
| Login | Usuario inicia sesión por email/contraseña y se redirige según rol. |
| Registro actividad | Estudiante crea actividad ligada a práctica activa con estado `registrado`. |
| Revisión | Tutor/supervisor cambia estado y deja observación visible en detalle. |
| QR asistencia | Escaneo válido registra entrada/salida con reglas de secuencia. |
| Reporte semanal | Muestra total horas, cantidad de actividades y rango de fechas. |
| Coordinador | Dashboard con totales de prácticas activas y horas acumuladas. |

### Datos demo (migraciones 002–005)

La migración **005** asigna `empresa_id` a supervisores existentes. El supervisor demo queda vinculado a **Tech Solutions SAC** y ve todas las prácticas activas de esa empresa.

| Email | Contraseña | Rol |
|-------|------------|-----|
| `estudiante@demo.com` | `123456` | estudiante |
| `tutor@demo.com` | `123456` | tutor |
| `supervisor@demo.com` | `123456` | supervisor |
| `coord@demo.com` | `123456` | coordinador |

---

## Recursos Flutter

- [Documentación Flutter](https://docs.flutter.dev/)
- [sqflite](https://pub.dev/packages/sqflite)
 