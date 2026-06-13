import 'package:following_practices/back/services/actividad_service.dart' as back;
import 'package:following_practices/back/services/alerta_service.dart' as back;
import 'package:following_practices/back/services/asistencia_service.dart' as back;
import 'package:following_practices/back/services/auth_service.dart' as back;
import 'package:following_practices/back/services/coordinador_service.dart' as back;
import 'package:following_practices/back/services/practica_service.dart' as back;

/// Singletons de servicios del back compartidos en el front.
class ServiceLocator {
  ServiceLocator._();

  static final auth = back.AuthService();
  static final actividad = back.ActividadService();
  static final practica = back.PracticaService();
  static final asistencia = back.AsistenciaService();
  static final coordinador = back.CoordinadorService();
  static final alerta = back.AlertaService();
}
