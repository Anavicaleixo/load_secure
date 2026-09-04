import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/supabase/auth_service.dart';

class LoadSecureApp extends StatefulWidget {
  const LoadSecureApp({super.key});

  @override
  State<LoadSecureApp> createState() => _LoadSecureAppState();
}

class _LoadSecureAppState extends State<LoadSecureApp> {
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    // Escuta eventos de autenticação do Supabase.
    // Quando o usuário clica no link de recuperação de senha no e-mail,
    // o Supabase dispara o evento passwordRecovery → redireciona para /update-password.
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        AppRoutes.router.go(AppRoutes.updatePassword);
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp.router(
        title: 'LoadSecure',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
