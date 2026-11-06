import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/supabase/auth_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/legal_terms.dart';
import '../../../core/utils/file_downloader/file_downloader.dart';

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
  final _regCompanyCtrl  = TextEditingController();
  final _regPhoneCtrl    = TextEditingController();
  final _regPassCtrl     = TextEditingController();
  final _regConfirmCtrl  = TextEditingController();
  final _regFormKey      = GlobalKey<FormState>();
  bool _obscureReg       = true;
  bool _acceptedTerms    = false;

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
    _regCompanyCtrl.dispose();
    _regPhoneCtrl.dispose();
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
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aceite os termos de uso para continuar.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthService>();
      await auth.signUpWithEmail(
        name: _regNameCtrl.text,
        email: _regEmailCtrl.text,
        password: _regPassCtrl.text,
        company: _regCompanyCtrl.text,
        phone: _regPhoneCtrl.text,
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

  // ─── Termos de Uso e Privacidade (Download e Visualização) ────────────────
  Future<void> _downloadTermsPdf() async {
    try {
      final byteData = await rootBundle.load('assets/docs/termos_de_uso_e_politica_de_privacidade.pdf');
      final bytes = byteData.buffer.asUint8List();
      final destination = await FileDownloader.downloadBytes(
        bytes: bytes,
        filename: 'Termos_e_Privacidade_LoadSecure.pdf',
        mimeType: 'application/pdf',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    destination != null
                        ? 'PDF baixado com sucesso! ($destination)'
                        : 'Download do PDF iniciado.',
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (_) {
      // Fallback para TXT caso ocorra algum erro no carregamento do PDF
      await _downloadTermsTxt();
    }
  }

  Future<void> _downloadTermsTxt() async {
    try {
      final destination = await FileDownloader.downloadText(
        text: LegalTerms.fullDocument,
        filename: 'Termos_e_Privacidade_LoadSecure.txt',
        mimeType: 'text/plain;charset=utf-8',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    destination != null
                        ? 'Documento baixado com sucesso! ($destination)'
                        : 'Download do documento iniciado.',
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao baixar documento: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showTermsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.red.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.red,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Termos de Uso e Privacidade',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'LOADSECURE • Versão Oficial 1.0 (LGPD)',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botões de Download direto
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _downloadTermsPdf();
                          },
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                          label: Text(
                            'Baixar PDF',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _downloadTermsTxt();
                          },
                          icon: const Icon(Icons.download_rounded, size: 18, color: AppColors.textPrimary),
                          label: Text(
                            'Baixar TXT',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Texto dos termos rolável
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Text(
                          LegalTerms.fullDocument,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            height: 1.55,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botão Aceitar e Fechar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _acceptedTerms = true);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Aceitar Termos e Fechar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
          // Nome completo
          _fieldLabel('Nome completo'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regNameCtrl,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Seu nome completo',
              prefixIcon: Icon(Icons.person_outline, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Informe o nome';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // E-mail
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
          const SizedBox(height: 16),

          // Empresa
          _fieldLabel('Empresa'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regCompanyCtrl,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Nome da empresa',
              prefixIcon: Icon(Icons.business_outlined, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Informe a empresa';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Telefone
          _fieldLabel('Telefone'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _regPhoneCtrl,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              hintText: '(00) 00000-0000',
              prefixIcon: Icon(Icons.phone_outlined, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Informe o telefone';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Senha
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
                  _obscureReg ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
          const SizedBox(height: 16),

          // Termos de uso
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: _acceptedTerms,
                  onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                  activeColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Aceito os ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => setState(() => _acceptedTerms = !_acceptedTerms),
                      ),
                      TextSpan(
                        text: 'termos de uso',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.red,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showTermsModal(context),
                      ),
                      TextSpan(
                        text: ' e ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextSpan(
                        text: 'política de privacidade',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.red,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showTermsModal(context),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.file_download_outlined,
                  color: AppColors.red,
                  size: 20,
                ),
                tooltip: 'Baixar documento em PDF',
                onPressed: _downloadTermsPdf,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Botão CADASTRAR
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onRegister,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
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
          const SizedBox(height: 24),

          // Link para login
          Center(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Já possui uma conta? ',
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    TextSpan(
                      text: 'Faça login',
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
                  // ── Imagem do dispositivo ──────────────────────────────
                  const SizedBox(height: 50),

                  // ── Imagem do dispositivo ──────────────────────────────
                  Transform.scale(
                    scale: 1.35,
                    child: SizedBox(
                      height: 270,
                      width: double.infinity,
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black,
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black,
                            ],
                            stops: [0.0, 0.15, 0.85, 1.0],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstOut,
                        child: Image.asset(
                          'assets/images/device.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const _DevicePlaceholder(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

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
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: AppColors.red, size: 28),
        ),
        const SizedBox(width: 16),
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
