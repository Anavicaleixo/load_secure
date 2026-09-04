import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_routes.dart';

/// Tela exibida quando o usuário clica no link de redefinição de senha
/// do e-mail. Permite cadastrar uma nova senha.
class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;
  bool _success        = false;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passCtrl.text),
      );
      if (mounted) setState(() => _success = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // Glow topo
            Positioned(
              top: -80,
              left: 0,
              right: 0,
              child: Container(
                height: 320,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.9,
                    colors: [Color(0x44E53935), Color(0x00000000)],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _success ? _buildSuccess() : _buildForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Formulário de nova senha ────────────────────────────────────────────
  Widget _buildForm() {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.red, AppColors.redDark],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.red.withAlpha(80),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            'Criar nova senha',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Escolha uma senha forte para proteger sua conta LoadSecure.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 36),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nova senha
                _label('Nova senha'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  style: GoogleFonts.inter(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Mínimo 6 caracteres',
                    prefixIcon:
                        const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                      icon: Icon(
                        _obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a nova senha';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Confirmar senha
                _label('Confirmar nova senha'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  style: GoogleFonts.inter(
                      color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Repita a nova senha',
                    prefixIcon:
                        const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirme a nova senha';
                    if (v != _passCtrl.text) return 'As senhas não coincidem';
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // Botão
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updatePassword,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(
                            'SALVAR NOVA SENHA',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Estado de sucesso ───────────────────────────────────────────────────
  Widget _buildSuccess() {
    return Padding(
      key: const ValueKey('success'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withAlpha(20),
                border: Border.all(color: AppColors.success, width: 2),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.success,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Senha redefinida!',
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sua senha foi atualizada com sucesso.\nAgora você pode fazer login normalmente.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.onboarding),
              child: Text(
                'IR PARA O LOGIN',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      );
}
