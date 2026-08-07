import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço de autenticação via Supabase.
class AuthService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // ─── Stream de mudanças de sessão ────────────────────────────────────────
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ─── Login com E-mail + Senha ─────────────────────────────────────────────
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    notifyListeners();
    return response;
  }

  // ─── Cadastro com E-mail + Senha ─────────────────────────────────────────
  Future<AuthResponse> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'name': name.trim()},
    );
    notifyListeners();
    return response;
  }

  // ─── Login com Google (OAuth) ─────────────────────────────────────────────
  /// Requer configuração do provider Google no painel do Supabase.
  Future<bool> signInWithGoogle() async {
    final result = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'io.supabase.loadsecure://login-callback',
    );
    notifyListeners();
    return result;
  }

  // ─── Login com Microsoft (OAuth) ─────────────────────────────────────────
  /// Requer configuração do provider Azure no painel do Supabase.
  Future<bool> signInWithMicrosoft() async {
    final result = await _client.auth.signInWithOAuth(
      OAuthProvider.azure,
      redirectTo: kIsWeb ? null : 'io.supabase.loadsecure://login-callback',
    );
    notifyListeners();
    return result;
  }

  // ─── Recuperação de Senha ─────────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email.trim(),
      // No web usa null → Supabase usa a Site URL configurada no painel.
      // No mobile usa o deep link do app.
      redirectTo: kIsWeb
          ? null
          : 'io.supabase.loadsecure://reset-callback',
    );
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _client.auth.signOut();
    notifyListeners();
  }

  // ─── Dados do perfil do usuário atual ────────────────────────────────────
  Future<Map<String, dynamic>?> fetchProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    return data;
  }
}
