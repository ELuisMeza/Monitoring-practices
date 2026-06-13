/// Validaciones compartidas de entrada.
class InputValidator {
  InputValidator._();

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  static final _fechaRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El email es obligatorio.';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Email inválido.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres.';
    }
    return null;
  }

  static String? requiredText(String? value, {String label = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label es obligatorio.';
    }
    return null;
  }

  static String? fechaIso(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La fecha es obligatoria.';
    }
    if (!_fechaRegex.hasMatch(value.trim())) {
      return 'Formato YYYY-MM-DD.';
    }
    final parts = value.split('-');
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return 'Fecha inválida.';
    }
    try {
      DateTime(year, month, day);
    } catch (_) {
      return 'Fecha inválida.';
    }
    return null;
  }

  static String? horasPositivas(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Las horas son obligatorias.';
    }
    final horas = double.tryParse(value.replaceAll(',', '.'));
    if (horas == null || horas <= 0) {
      return 'Debe ser un número mayor a 0.';
    }
    return null;
  }

  static String? rol(String? value) {
    const roles = {'estudiante', 'tutor', 'supervisor', 'coordinador'};
    if (value == null || !roles.contains(value)) {
      return 'Rol inválido.';
    }
    return null;
  }

  static String? estadoActividad(String? value) {
    const estados = {'registrado', 'observado', 'aprobado', 'rechazado'};
    if (value == null || !estados.contains(value)) {
      return 'Estado de actividad inválido.';
    }
    return null;
  }

  static String formatoFecha(DateTime fecha) {
    final y = fecha.year.toString().padLeft(4, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String formatoHora(DateTime fecha) {
    final h = fecha.hour.toString().padLeft(2, '0');
    final m = fecha.minute.toString().padLeft(2, '0');
    final s = fecha.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
