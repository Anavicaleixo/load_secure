import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/update_password_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/machines/screens/machines_list_screen.dart';
import '../../features/machines/screens/machine_detail_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/setup/screens/sql_setup_screen.dart';

/// Rotas nomeadas da aplicação LoadSecure.
abstract class AppRoutes {
  // --- Route Paths ---
  static const String onboarding     = '/';
  static const String forgotPassword = '/forgot-password';
  static const String updatePassword = '/update-password';
  static const String dashboard      = '/dashboard';
  static const String machines      = '/machines';
  static const String machineDetail = '/machines/:id';
  static const String profile       = '/profile';
  static const String sqlSetup      = '/sql-setup';

  // --- GoRouter Config ---
  static final GoRouter router = GoRouter(
    initialLocation: onboarding,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final loc = state.matchedLocation;
      // Não redirecionar quem está em update-password ou forgot-password
      if (loc == updatePassword || loc == forgotPassword) return null;
      // Se logado e na tela de onboarding → vai para dashboard
      if (session != null && loc == onboarding) return dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => ForgotPasswordScreen(
          initialEmail: state.extra as String?,
        ),
      ),
      GoRoute(
        path: updatePassword,
        name: 'updatePassword',
        builder: (context, state) => const UpdatePasswordScreen(),
      ),
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: machines,
        name: 'machines',
        builder: (context, state) => const MachinesListScreen(),
      ),
      GoRoute(
        path: machineDetail,
        name: 'machineDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MachineDetailScreen(machineId: id);
        },
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: sqlSetup,
        name: 'sqlSetup',
        builder: (context, state) => const SqlSetupScreen(),
      ),
    ],
  );
}
