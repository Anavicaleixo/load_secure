import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/supabase/auth_service.dart';
import '../../../core/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final TabController _tabController;
  int _currentPage = 0;

  // Login controllers
  final _loginEmailCtrl    = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  final _loginFormKey      = GlobalKey<FormState>();
  bool _obscureLogin       = true;

  // Register controllers
  final _regNameCtrl     = TextEditingController();
  final _regEmailCtrl    = TextEditingController();
  final _regPassCtrl     = TextEditingController();
  final _regConfirmCtrl  = TextEditingController();
  final _regFormKey      = GlobalKey<FormState>();
  bool _obscureReg       = true;
  bool _obscureRegConf   = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthService>();
      await auth.signInWithEmail(
        email: _loginEmailCtrl.text,
        password: _loginPasswordCtrl.text,
      );
      if (mounted) context.go(AppRoutes.dashboard);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao entrar: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRegister() async {
    if (!_regFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthService>();
      await auth.signUpWithEmail(
        name: _regNameCtrl.text,
        email: _regEmailCtrl.text,
        password: _regPassCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado! Verifique seu e-mail.'),
            backgroundColor: AppColors.success,
          ),
        );
        _tabController.animateTo(0);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no cadastro: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro Google: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onMicrosoftLogin() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().signInWithMicrosoft();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro Microsoft: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final keyboardOpen = bottomInset > 50;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ── PageView ──────────────────────────────────────────────────────
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              _WelcomePage(onGetStarted: () => _goToPage(1)),
              _buildAuthPage(),
            ],
          ),

          // ── Dots — visíveis em ambas as páginas (some com teclado aberto) ─
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: keyboardOpen ? -40 : 20,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: keyboardOpen ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _goToPage(0),
                    child: _Dot(active: _currentPage == 0),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _goToPage(1),
                    child: _Dot(active: _currentPage == 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Página 2: Auth ───────────────────────────────────────────────────────
  Widget _buildAuthPage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Título ────────────────────────────────────────────────────
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Bem-vindo ao\n',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: 'Load',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextSpan(
                      text: 'Secure',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Faça login para acessar sua conta',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // ── Tabs ──────────────────────────────────────────────────────
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'LOGIN'),
                  Tab(text: 'CADASTRO'),
                ],
              ),
              const SizedBox(height: 28),

              // ── Conteúdo das Tabs ─────────────────────────────────────────
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  if (_tabController.index == 0) {
                    return _buildLoginForm();
                  } else {
                    return _buildRegisterForm();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Formulário de Login ──────────────────────────────────────────────────
  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('E-mail'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'seu@email.com',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
              if (!v.contains('@')) return 'E-mail inválido';
              return null;
            },
          ),
          const SizedBox(height: 20),

          _fieldLabel('Senha'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginPasswordCtrl,
            obscureText: _obscureLogin,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Sua senha',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureLogin = !_obscureLogin),
                icon: Icon(
                  _obscureLogin
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe a senha';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 10),

          // Esqueceu senha → nova tela
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => context.push(
                AppRoutes.forgotPassword,
                extra: _loginEmailCtrl.text.trim(),
              ),
              child: Text(
                'Esqueceu sua senha?',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Botão ENTRAR
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onLogin,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      'ENTRAR',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Divisor "ou"
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('ou',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary)),
              ),
              const Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 16),

          _socialButton(
            onTap: _isLoading ? null : _onGoogleLogin,
            icon: _googleIcon(),
            label: 'Entrar com Google',
          ),
          const SizedBox(height: 12),
          _socialButton(
            onTap: _isLoading ? null : _onMicrosoftLogin,
            icon: _microsoftIcon(),
            label: 'Entrar com Microsoft',
          ),
          const SizedBox(height: 28),

          Center(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(1),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Ainda não tem uma conta? ',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textPrimary),
                    ),
                    TextSpan(
                      text: 'Cadastre-se',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Formulário de Cadastro ───────────────────────────────────────────────
  Widget _buildRegisterForm() {
    return Form(
      key: _regFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel('Nome completo'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regNameCtrl,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Seu nome',
              prefixIcon: Icon(Icons.person_outline, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Informe o nome';
              return null;
            },
          ),
          const SizedBox(height: 20),

          _fieldLabel('E-mail'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'seu@email.com',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
              if (!v.contains('@')) return 'E-mail inválido';
              return null;
            },
          ),
          const SizedBox(height: 20),

          _fieldLabel('Senha'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regPassCtrl,
            obscureText: _obscureReg,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Crie uma senha',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureReg = !_obscureReg),
                icon: Icon(
                  _obscureReg
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe a senha';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 20),

          _fieldLabel('Confirmar senha'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regConfirmCtrl,
            obscureText: _obscureRegConf,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Repita a senha',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscureRegConf = !_obscureRegConf),
                icon: Icon(
                  _obscureRegConf
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirme a senha';
              if (v != _regPassCtrl.text) return 'Senhas não coincidem';
              return null;
            },
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onRegister,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      'CADASTRAR',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Já tem uma conta? ',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textPrimary),
                    ),
                    TextSpan(
                      text: 'Entrar',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Widget _fieldLabel(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      );

  Widget _socialButton({
    required VoidCallback? onTap,
    required Widget icon,
    required String label,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _googleIcon() => SizedBox(
        width: 22,
        height: 22,
        child: CustomPaint(painter: _GoogleIconPainter()),
      );

  Widget _microsoftIcon() => SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(painter: _MicrosoftIconPainter()),
      );
}

// ─── Widget: WelcomePage (Página 1) ──────────────────────────────────────────
class _WelcomePage extends StatelessWidget {
  final VoidCallback onGetStarted;
  const _WelcomePage({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        children: [
          // Glow vermelho no topo
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.9,
                  colors: [Color(0x55E53935), Color(0x00000000)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 48, 32, 60),
              child: Column(
                children: [
                  // ── Logo ────────────────────────────────────────────────
                  const _ShieldLogo(),
                  const SizedBox(height: 20),

                  // ── Nome ────────────────────────────────────────────────
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'LOAD',
                          style: GoogleFonts.rajdhani(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: 2,
                          ),
                        ),
                        TextSpan(
                          text: 'SECURE',
                          style: GoogleFonts.rajdhani(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: AppColors.red,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'MONITORAMENTO INTELIGENTE\nDE CARGAS',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      letterSpacing: 2.5,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Imagem do dispositivo ──────────────────────────────
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      'assets/images/device.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const _DevicePlaceholder(),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Features ────────────────────────────────────────────
                  const _FeatureItem(
                    icon: Icons.shield_outlined,
                    title: 'Proteção completa',
                    description:
                        'Detecta impacto, vibração, violação e desvios de rota.',
                  ),
                  const SizedBox(height: 20),
                  const _FeatureItem(
                    icon: Icons.location_on_outlined,
                    title: 'Rastreamento em tempo real',
                    description:
                        'Acompanhe cada movimentação da sua carga.',
                  ),
                  const SizedBox(height: 20),
                  const _FeatureItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Análise inteligente',
                    description:
                        'Dados que transformam informação em decisão.',
                  ),
                  const SizedBox(height: 36),

                  // ── Footer ──────────────────────────────────────────────
                  GestureDetector(
                    onTap: onGetStarted,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Segurança e inteligência em ',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: 'cada movimento.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget: Escudo ───────────────────────────────────────────────────────────
class _ShieldLogo extends StatelessWidget {
  const _ShieldLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.red.withAlpha(80),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              gradient: AppColors.accentGradient,
              shape: BoxShape.circle,
            ),
          ),
          const Icon(Icons.lock_rounded, color: Colors.white, size: 36),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: CustomPaint(
              size: const Size(double.infinity, 14),
              painter: _HeartbeatPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget: Feature Item ─────────────────────────────────────────────────────
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            border:
                Border.all(color: AppColors.red.withAlpha(120), width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.red, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Widget: Bolinha ──────────────────────────────────────────────────────────
class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.red : AppColors.textDisabled,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─── Widget: Device Placeholder ───────────────────────────────────────────────
class _DevicePlaceholder extends StatelessWidget {
  const _DevicePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(Icons.devices, color: AppColors.red, size: 64),
    );
  }
}

// ─── Painter: Heartbeat ───────────────────────────────────────────────────────
class _HeartbeatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(180)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    final w = size.width;
    final mid = size.height / 2;
    path.moveTo(0, mid);
    path.lineTo(w * 0.25, mid);
    path.lineTo(w * 0.35, mid - size.height * 0.8);
    path.lineTo(w * 0.45, mid + size.height * 0.6);
    path.lineTo(w * 0.55, mid - size.height * 0.4);
    path.lineTo(w * 0.65, mid);
    path.lineTo(w, mid);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HeartbeatPainter old) => false;
}

// ─── Painter: Google Icon ─────────────────────────────────────────────────────
class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    final tp = TextPainter(
      text: TextSpan(
        text: 'G',
        style: TextStyle(
          color: const Color(0xFF4285F4),
          fontSize: size.width * 0.72,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_GoogleIconPainter old) => false;
}

// ─── Painter: Microsoft Icon ──────────────────────────────────────────────────
class _MicrosoftIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final half = size.width / 2;
    final gap = size.width * 0.06;
    final colors = [
      const Color(0xFFF25022),
      const Color(0xFF7FBA00),
      const Color(0xFF00A4EF),
      const Color(0xFFFFB900),
    ];
    final rects = [
      Rect.fromLTWH(0, 0, half - gap, half - gap),
      Rect.fromLTWH(half + gap, 0, half - gap, half - gap),
      Rect.fromLTWH(0, half + gap, half - gap, half - gap),
      Rect.fromLTWH(half + gap, half + gap, half - gap, half - gap),
    ];
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(rects[i], Paint()..color = colors[i]);
    }
  }

  @override
  bool shouldRepaint(_MicrosoftIconPainter old) => false;
}
