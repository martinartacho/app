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

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
              Text('Ajuda', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                'Per a qualsevol dubte o suggeriment, contacta amb el responsable de la teva colla '
                'o envia un correu a l\'administrador de l\'aplicació.',
              ),
              const SizedBox(height: 24),
              Text('Preguntes freqüents', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('• No veig les meves rondes → Comprova que la teva colla té actuacions publicades.'),
              const SizedBox(height: 4),
              const Text('• Error d\'inici de sessió → Verifica el correu i la contrasenya.'),

              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 24),

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
