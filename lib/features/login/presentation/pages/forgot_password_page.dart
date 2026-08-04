import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:femcastells/core/network/dio_factory.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  bool _sending = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Introdueix el teu correu electrònic.');
      return;
    }
    setState(() { _sending = true; _error = null; });
    try {
      await DioFactory.getInstance().post('/api/forgot-password', data: {'email': email});
      if (!mounted) return;
      setState(() { _sending = false; _sent = true; });
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? 'Error en enviar. Torna-ho a provar.';
      setState(() { _sending = false; _error = msg.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contrasenya')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Introdueix el teu correu i t\'enviarem un link per restablir la contrasenya.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            if (_sent) ...[
              Icon(Icons.mark_email_read_outlined, size: 64, color: Colors.green[700]),
              const SizedBox(height: 16),
              Text(
                'Comprova el teu correu. Si el compte existeix, rebràs un link per restablir la contrasenya.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tornar al login'),
                ),
              ),
            ] else ...[
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  labelText: 'Correu electrònic',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _sending ? null : _send,
                  child: _sending
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Enviar link'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
