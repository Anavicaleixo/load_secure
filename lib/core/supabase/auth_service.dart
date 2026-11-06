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
    required String company,
    required String phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'name': name.trim(),
        'company': company.trim(),
        'phone': phone.trim(),
      },
    );
    notifyListeners();
    return response;
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
