import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/supabase/sql_scripts.dart';

/// Tela que exibe os scripts SQL para criação das tabelas no Supabase.
/// Acesse em: Painel Supabase → SQL Editor → Cole e execute.
class SqlSetupScreen extends StatefulWidget {
  const SqlSetupScreen({super.key});

  @override
  State<SqlSetupScreen> createState() => _SqlSetupScreenState();
}

class _SqlSetupScreenState extends State<SqlSetupScreen> {
  int _expandedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Configuração do Banco'),
        leading: const BackButton(),
        actions: [
          IconButton(
            tooltip: 'Abrir Supabase',
            icon: const Icon(Icons.open_in_new),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Acesse: supabase.com/dashboard/project/xbtlhqfbqvjgyqdhnsst/sql',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Info header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.red.withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.red, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Execute os scripts abaixo no SQL Editor do Supabase.\n'
                    'Execute na ordem: Profiles → Sectors → Machines → Alerts.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Scripts SQL ──────────────────────────────────────────────────
          ...SqlScripts.all.asMap().entries.map((entry) {
            final i = entry.key;
            final script = entry.value;
            final isExpanded = _expandedIndex == i;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isExpanded ? AppColors.red : AppColors.border,
                    width: isExpanded ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    InkWell(
                      onTap: () => setState(
                        () => _expandedIndex = isExpanded ? -1 : i,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.table_chart_outlined,
                                color: AppColors.red, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              script['title']!,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // SQL expandido
                    if (isExpanded) ...[
                      const Divider(height: 1, color: AppColors.border),
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            color: AppColors.backgroundDark,
                            child: Text(
                              script['sql']!,
                              style: GoogleFonts.sourceCodePro(
                                fontSize: 11.5,
                                color: const Color(0xFF80CBC4),
                                height: 1.6,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              tooltip: 'Copiar SQL',
                              icon: const Icon(
                                Icons.copy_rounded,
                                color: AppColors.textSecondary,
                                size: 18,
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: script['sql']!),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${script['title']} copiado!',
                                    ),
                                    backgroundColor: AppColors.success,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          // Copiar tudo
          OutlinedButton.icon(
            onPressed: () {
              final all = SqlScripts.all
                  .map((s) => '-- ${s['title']}\n${s['sql']}')
                  .join('\n\n');
              Clipboard.setData(ClipboardData(text: all));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todos os scripts copiados!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.copy_all_rounded, size: 18),
            label: const Text('Copiar todos os scripts'),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
