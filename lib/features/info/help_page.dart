import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:femcastells/core/network/dio_factory.dart';
import 'package:femcastells/features/menu/presentation/widgets/arc_menu.dart';
import 'package:femcastells/l10n/app_localizations.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final _ctrl = TextEditingController();
  bool _sending = false;
  String? _feedback;
  bool _isError = false;

  // FAQ dinàmica
  List<_HelpCategory> _categories = [];
  bool _loadingFaq = true;

  @override
  void initState() {
    super.initState();
    _loadFaq();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadFaq() async {
    try {
      final response = await DioFactory.getInstance().get('/api-fempinya/mobile_help');
      final items = (response.data as List).cast<Map<String, dynamic>>();
      final Map<String, List<_HelpItem>> grouped = {};
      for (final item in items) {
        final cat = item['category'] as String;
        grouped.putIfAbsent(cat, () => []).add(_HelpItem(
          question: item['question'] as String,
          answer:   item['answer']   as String,
        ));
      }
      if (mounted) {
        setState(() {
          _categories = grouped.entries
              .map((e) => _HelpCategory(name: e.key, items: e.value))
              .toList();
          _loadingFaq = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingFaq = false);
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.length < 10) {
      setState(() { _feedback = 'El missatge ha de tenir com a mínim 10 caràcters.'; _isError = true; });
      return;
    }
    setState(() { _sending = true; _feedback = null; });
    try {
      await DioFactory.getInstance().post('/api-fempinya/mobile_suggeriment', data: {'text': text});
      if (!mounted) return;
      _ctrl.clear();
      setState(() { _sending = false; _feedback = 'Suggeriment enviat. Gràcies!'; _isError = false; });
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? 'Error en enviar. Torna-ho a provar.';
      setState(() { _sending = false; _feedback = msg.toString(); _isError = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ArcMenu(
      child: Scaffold(
        appBar: AppBar(title: Text(t.menuHelp)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── FAQ dinàmica ──
              Text('Ajuda', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              if (_loadingFaq)
                const Center(child: CircularProgressIndicator())
              else if (_categories.isEmpty)
                Text(
                  'Per a qualsevol dubte, contacta amb el responsable de la teva colla.',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                )
              else
                ..._categories.map((cat) => _CategorySection(category: cat, theme: theme)),

              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 24),

              // ── Suggeriments ──
              Text('Envia un suggeriment', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('El teu missatge arribarà directament a l\'administrador de la colla.'),
              const SizedBox(height: 16),

              TextField(
                controller: _ctrl,
                maxLines: 5,
                maxLength: 2000,
                decoration: const InputDecoration(
                  hintText: 'Escriu aquí el teu suggeriment o comentari...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              if (_feedback != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _feedback!,
                    style: TextStyle(color: _isError ? theme.colorScheme.error : Colors.green[700]),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _sending ? null : _send,
                  child: _sending
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Enviar suggeriment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Models locals ──

class _HelpCategory {
  final String name;
  final List<_HelpItem> items;
  const _HelpCategory({required this.name, required this.items});
}

class _HelpItem {
  final String question;
  final String answer;
  const _HelpItem({required this.question, required this.answer});
}

// ── Widgets ──

class _CategorySection extends StatelessWidget {
  final _HelpCategory category;
  final ThemeData theme;
  const _CategorySection({required this.category, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          category.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        ...category.items.map((item) => _FaqTile(item: item)),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  final _HelpItem item;
  const _FaqTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(item.question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          child: Text(item.answer, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
