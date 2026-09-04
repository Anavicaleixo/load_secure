import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/supabase/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  int _columnsPage = 0;
  final PageController _columnsPageCtrl = PageController();
  final ScrollController _mainScrollCtrl = ScrollController();

  @override
  void dispose() {
    _columnsPageCtrl.dispose();
    _mainScrollCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      _mainScrollCtrl.animateTo(
        _mainScrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(milliseconds: 300), () {
        _columnsPageCtrl.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        setState(() => _columnsPage = 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final userName = authService.currentUser?.userMetadata?['name'] ?? 'Usuário';
    final firstName = userName.split(' ').first;
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        controller: _mainScrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(firstName),
            const SizedBox(height: 24),
            _buildCriticalAlert(),
            const SizedBox(height: 24),
            _buildSwipeHint(),
            _buildSummaryCards(),
            const SizedBox(height: 24),
            _buildCriticalPoints(),
            const SizedBox(height: 24),
            _buildTwoColumnsSection(),
          ],
        ),
      ),
      floatingActionButton: _buildScanFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () {}),
      title: RichText(
        text: TextSpan(children: [
          TextSpan(text: 'LOAD', style: GoogleFonts.rajdhani(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.5)),
          TextSpan(text: 'SECURE', style: GoogleFonts.rajdhani(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.red, letterSpacing: 1.5)),
        ]),
      ),
      centerTitle: true,
      actions: [
        Stack(alignment: Alignment.center, children: [
          IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Colors.white), onPressed: () {}),
          Positioned(top: 12, right: 12, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle))),
        ]),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildGreeting(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bem-vindo, $name!', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 6),
        Text('Visão geral em tempo real dos impactos e indicadores', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
      ],
    );
  }

  Widget _buildCriticalAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.red.withAlpha(15), border: Border.all(color: AppColors.red.withAlpha(50)), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 32),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('4 Impacto(s) crítico(s) detectado(s)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.red)),
          const SizedBox(height: 4),
          Text('Verifique as movimentações afetadas e ordens de inspeção geradas.', style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, height: 1.3)),
        ])),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12), minimumSize: const Size(0, 36), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          child: Row(children: [
            Text('Ver', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, size: 14),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSwipeHint() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text('Deslize para ver mais', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(width: 4),
        const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.textSecondary),
      ]),
    );
  }

  Widget _buildSummaryCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(width: 160, child: _SummaryCard(title: 'MOVIMENTAÇÕES', value: '18', subtitle: 'Total registradas', icon: Icons.local_shipping_outlined)),
          const SizedBox(width: 12),
          SizedBox(width: 180, child: _SummaryCard(title: 'IMPACTOS DETECTADOS', value: '28', subtitle: '▼ 12% vs. período anterior', subtitleColor: AppColors.red, icon: Icons.bolt_outlined)),
          const SizedBox(width: 12),
          SizedBox(width: 160, child: _SummaryCard(title: 'REDUÇÃO DE PERDAS', value: '65%', subtitle: 'Após implantação', icon: Icons.trending_down_rounded)),
        ]),
      ),
    );
  }

  Widget _buildCriticalPoints() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withAlpha(10), width: 1), boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.location_on_outlined, color: AppColors.red, size: 20),
          const SizedBox(width: 8),
          Text('Pontos críticos da fábrica', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        ]),
        const SizedBox(height: 24),
        _buildPointRow(1, 'Rampa Expedição', '6'),
        _buildPointRow(2, 'Estoque 3', '6'),
        _buildPointRow(3, 'Setor de QA', '4'),
        _buildPointRow(4, 'Doca de Recebimento', '4'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Row(children: [
            Text('Ver mapa completo', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.red)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, color: AppColors.red, size: 14),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPointRow(int index, String name, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        Container(width: 24, height: 24, decoration: BoxDecoration(color: AppColors.red.withAlpha(20), shape: BoxShape.circle), child: Center(child: Text(index.toString(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.red)))),
        const SizedBox(width: 12),
        Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
        const Spacer(),
        Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
      ]),
    );
  }

  Widget _buildTwoColumnsSection() {
    return Column(children: [
      Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              _columnsPageCtrl.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              setState(() => _columnsPage = 0);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: _columnsPage == 0 ? AppColors.red : AppColors.surface,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              ),
              child: Text('Impactos recentes', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _columnsPage == 0 ? Colors.white : AppColors.textSecondary)),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _columnsPageCtrl.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              setState(() => _columnsPage = 1);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: _columnsPage == 1 ? AppColors.red : AppColors.surface,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
              child: Text('Cargas monitoradas', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _columnsPage == 1 ? Colors.white : AppColors.textSecondary)),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 12),
      SizedBox(
        height: 480,
        child: PageView(
          controller: _columnsPageCtrl,
          onPageChanged: (i) => setState(() => _columnsPage = i),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withAlpha(10), width: 1), boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 10, offset: const Offset(0, 4))]),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildImpactItem('Alto', 'Corredor Central', '27/03/2026, 21:33', '9.9 g', AppColors.red),
                  _buildImpactItem('Médio', 'Rampa Expedição', '27/03/2026, 21:22', '5.7 g', Colors.orange),
                  _buildImpactItem('Médio', 'Setor de QA', '27/03/2026, 21:12', '5.3 g', Colors.orange),
                  _buildImpactItem('Crítico', 'Linha de Produção 1', '27/03/2026, 15:54', '13.4 g', AppColors.red),
                  _buildImpactItem('Médio', 'Estoque 3', '27/03/2026, 01:41', '6.1 g', Colors.orange),
                ]),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withAlpha(10), width: 1), boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 10, offset: const Offset(0, 4))]),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _buildLoadItem('Monitor Industrial', 'Caixa - alta fragilidade', '0 impactos', 'Alto', AppColors.red),
                  _buildLoadItem('Motor Elétrico', 'Pallet - média fragilidade', '0 impactos', 'Médio', Colors.orange),
                  _buildLoadItem('Produtos Químicos', 'Container - baixa fragilidade', '0 impactos', 'Alto', AppColors.red),
                  _buildLoadItem('Vidros Temp.', 'Pallet - alta fragilidade', '0 impactos', 'Alto', AppColors.red),
                  _buildLoadItem('Bebidas Envasadas', 'Caixa comum', '0 impactos', 'Médio', Colors.orange),
                ]),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildImpactItem(String badgeText, String location, String date, String gForce, Color color) {
    return GestureDetector(
      onTap: () => _showImpactModal(context, badgeText, location, date, gForce, color),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.backgroundDark, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(4)),
              child: Row(children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(badgeText, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              ]),
            ),
            const SizedBox(width: 4),
            Expanded(child: Text(date, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(location, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white), overflow: TextOverflow.ellipsis)),
            Text(gForce, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
        ]),
      ),
    );
  }

  void _showImpactModal(BuildContext ctx, String badge, String location, String date, String gForce, Color color) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(6)),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(badge, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
              ]),
            ),
            const Spacer(),
            Text(date, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 20),
          Text('Detalhes do Impacto', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          _modalRow(Icons.location_on_outlined, 'Local', location, color),
          const SizedBox(height: 12),
          _modalRow(Icons.bolt_outlined, 'Força do impacto', gForce, color),
          const SizedBox(height: 12),
          _modalRow(Icons.access_time_rounded, 'Data e hora', date, color),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () => Navigator.pop(_),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('Fechar', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          )),
        ]),
      ),
    );
  }

  Widget _buildLoadItem(String title, String desc, String impacts, String badgeText, Color color) {
    return GestureDetector(
      onTap: () => _showLoadModal(context, title, desc, impacts, badgeText, color),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.backgroundDark, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(4)),
              child: Row(children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(badgeText, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              ]),
            ),
            const SizedBox(width: 4),
            Expanded(child: Text(impacts.isNotEmpty ? impacts : 'Sem impactos', style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white), overflow: TextOverflow.ellipsis)),
            Flexible(child: Text(desc, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
          ]),
        ]),
      ),
    );
  }

  void _showLoadModal(BuildContext ctx, String title, String desc, String impacts, String badge, Color color) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(6)),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(badge, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          Text('Detalhes da Carga', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          _modalRow(Icons.inventory_2_outlined, 'Carga', title, color),
          const SizedBox(height: 12),
          _modalRow(Icons.category_outlined, 'Tipo / Embalagem', desc, color),
          const SizedBox(height: 12),
          _modalRow(Icons.bolt_outlined, 'Impactos registrados', impacts.isNotEmpty ? impacts : 'Nenhum', color),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () => Navigator.pop(_),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text('Fechar', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
          )),
        ]),
      ),
    );
  }

  Widget _modalRow(IconData icon, String label, String value, Color color) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis),
      ])),
    ]);
  }

  Widget _buildScanFab() {
    return Container(
      width: 60, height: 60,
      margin: const EdgeInsets.only(top: 30),
      decoration: BoxDecoration(color: AppColors.red, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.red.withAlpha(100), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 5))]),
      child: IconButton(icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28), onPressed: () {}),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(height: 60, child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _buildNavItem(Icons.home_filled, 'Início', 0),
        _buildNavItem(Icons.inventory_2_outlined, 'Cargas', 1),
        const SizedBox(width: 40),
        _buildNavItem(Icons.location_on_outlined, 'Mapas', 2),
        _buildNavItem(Icons.person_outline, 'Perfil', 3),
      ])),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.red : AppColors.textSecondary;
    return InkWell(
      onTap: () => _onNavTap(index),
      child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: color)),
      ]),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? subtitleColor;
  const _SummaryCard({required this.title, required this.value, required this.subtitle, required this.icon, this.subtitleColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(10), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Icon(icon, color: AppColors.textSecondary.withAlpha(150), size: 18),
        ]),
        const SizedBox(height: 14),
        Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 8),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: subtitleColor ?? AppColors.textSecondary, height: 1.2)),
      ]),
    );
  }
}
