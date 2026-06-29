import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:following_practices/front/components/loading_view.dart';
import 'package:following_practices/front/lib/theme/app_colors.dart';
import 'package:following_practices/front/pages/alertas_page.dart';
import 'package:following_practices/front/pages/auth/login_page.dart';
import 'package:following_practices/front/pages/coordinador/empresa_form_page.dart';
import 'package:following_practices/front/pages/coordinador/empresas_list_page.dart';
import 'package:following_practices/front/pages/coordinador/home_coordinador_page.dart';
import 'package:following_practices/front/pages/coordinador/practica_form_page.dart';
import 'package:following_practices/front/pages/coordinador/practicas_admin_list_page.dart';
import 'package:following_practices/front/pages/coordinador/practicas_list_page.dart';
import 'package:following_practices/front/pages/coordinador/usuario_form_page.dart';
import 'package:following_practices/front/pages/coordinador/usuarios_list_page.dart';
import 'package:following_practices/front/pages/crud_test_page.dart';
import 'package:following_practices/front/pages/shared/revision_detail_page.dart';
import 'package:following_practices/front/pages/shared/revision_queue_page.dart';
import 'package:following_practices/front/pages/student/actividad_detail_page.dart';
import 'package:following_practices/front/pages/student/actividad_form_page.dart';
import 'package:following_practices/front/pages/student/actividad_list_page.dart';
import 'package:following_practices/front/pages/student/home_estudiante_page.dart';
import 'package:following_practices/front/pages/student/perfil_practica_page.dart';
import 'package:following_practices/front/pages/student/qr_scan_page.dart';
import 'package:following_practices/front/pages/student/reporte_semanal_page.dart';
import 'package:following_practices/front/pages/supervisor/home_supervisor_page.dart';
import 'package:following_practices/front/pages/tutor/home_tutor_page.dart';
import 'package:following_practices/front/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final _authService = AuthService();

  static String _homePorRol(String rol) {
    switch (rol) {
      case 'tutor':
        return '/tutor';
      case 'supervisor':
        return '/supervisor';
      case 'coordinador':
        return '/coordinador';
      default:
        return '/estudiante';
    }
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final sesion = _authService.sesionActual ??
          await _authService.restaurarSesion();

      final enLogin = state.matchedLocation == '/login';
      final enSplash = state.matchedLocation == '/';

      if (enSplash) {
        return sesion == null ? '/login' : _homePorRol(sesion.rol);
      }
      if (sesion == null && !enLogin) return '/login';
      if (sesion != null && enLogin) return _homePorRol(sesion.rol);
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const _SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/estudiante', builder: (_, __) => const HomeEstudiantePage()),
      GoRoute(
        path: '/estudiante/actividad/nueva',
        builder: (_, __) => const ActividadFormPage(),
      ),
      GoRoute(
        path: '/estudiante/actividades',
        builder: (_, __) => const ActividadListPage(),
      ),
      GoRoute(
        path: '/estudiante/actividad/:id',
        builder: (_, state) => ActividadDetailPage(
          actividadId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(path: '/estudiante/qr', builder: (_, __) => const QrScanPage()),
      GoRoute(
        path: '/estudiante/reporte',
        builder: (_, __) => const ReporteSemanalPage(),
      ),
      GoRoute(
        path: '/estudiante/perfil',
        builder: (_, __) => const PerfilPracticaPage(),
      ),
      GoRoute(path: '/tutor', builder: (_, __) => const HomeTutorPage()),
      GoRoute(
        path: '/tutor/revision',
        builder: (_, __) => const RevisionQueuePage(modo: 'tutor'),
      ),
      GoRoute(path: '/supervisor', builder: (_, __) => const HomeSupervisorPage()),
      GoRoute(
        path: '/supervisor/validacion',
        builder: (_, __) => const RevisionQueuePage(modo: 'supervisor'),
      ),
      GoRoute(path: '/coordinador', builder: (_, __) => const HomeCoordinadorPage()),
      GoRoute(
        path: '/coordinador/practicas',
        builder: (_, __) => const PracticasListPage(),
      ),
      GoRoute(
        path: '/coordinador/usuarios',
        builder: (_, __) => const UsuariosListPage(),
      ),
      GoRoute(
        path: '/coordinador/usuarios/nuevo',
        builder: (_, __) => const UsuarioFormPage(),
      ),
      GoRoute(
        path: '/coordinador/usuarios/:id',
        builder: (_, state) => UsuarioFormPage(
          usuarioId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/coordinador/empresas',
        builder: (_, __) => const EmpresasListPage(),
      ),
      GoRoute(
        path: '/coordinador/empresas/nueva',
        builder: (_, __) => const EmpresaFormPage(),
      ),
      GoRoute(
        path: '/coordinador/empresas/:id',
        builder: (_, state) => EmpresaFormPage(
          empresaId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/coordinador/practicas-admin',
        builder: (_, __) => const PracticasAdminListPage(),
      ),
      GoRoute(
        path: '/coordinador/practicas-admin/nueva',
        builder: (_, __) => const PracticaFormPage(),
      ),
      GoRoute(
        path: '/coordinador/practicas-admin/:id',
        builder: (_, state) => PracticaFormPage(
          practicaId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/revision/:id',
        builder: (_, state) => RevisionDetailPage(
          actividadId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(path: '/alertas', builder: (_, __) => const AlertasPage()),
      if (kDebugMode)
        GoRoute(path: '/crud-test', builder: (_, __) => const CrudTestPage()),
    ],
  );
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_rounded, size: 72, color: Colors.white),
              SizedBox(height: 24),
              Text(
                'Seguimiento de Prácticas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 32),
              LoadingView(),
            ],
          ),
        ),
      ),
    );
  }
}
