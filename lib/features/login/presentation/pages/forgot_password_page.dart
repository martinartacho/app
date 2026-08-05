import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:femcastells/core/network/dio_factory.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Step 1 — email
  final _emailCtrl = TextEditingController();
  // Step 2 — code + new password
  final _codeCtrl        = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmCtrl     = TextEditingController();

  int _step = 1; // 1 = email, 2 = code+password, 3 = done
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Introdueix el teu correu electrònic.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await DioFactory.getInstance().post('/api/forgot-password', data: {'email': email});
      if (!mounted) return;
      setState(() { _loading = false; _step = 2; });
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? 'Error en enviar. Torna-ho a provar.';
      setState(() { _loading = false; _error = msg.toString(); });
    }
  }

  Future<void> _resetPassword() async {
    final code     = _codeCtrl.text.trim().toUpperCase();
    final password = _passwordCtrl.text;
    final confirm  = _confirmCtrl.text;

    if (code.isEmpty) {
      setState(() => _error = 'Introdueix el codi rebut per correu.');
      return;
    }
    if (password.length < 8) {
      setState(() => _error = 'La contrasenya ha de tenir mínim 8 caràcters.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Les contrasenyes no coincideixen.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await DioFactory.getInstance().post('/api/reset-password', data: {
        'email':                 _emailCtrl.text.trim(),
        'code':                  code,
        'password':              password,
        'password_confirmation': confirm,
      });
      if (!mounted) return;
      setState(() { _loading = false; _step = 3; });
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? 'Error en verificar el codi.';
      setState(() { _loading = false; _error = msg.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contrasenya')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: switch (_step) {
          1 => _buildStep1(theme),
          2 => _buildStep2(theme),
          _ => _buildDone(theme),
        },
      ),
    );
  }

  Widget _buildStep1(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Introdueix el teu correu i t\'enviarem un codi per restablir la contrasenya.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _loading ? null : _sendCode(),
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
            onPressed: _loading ? null : _sendCode,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Enviar codi'),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.mark_email_read_outlined, color: Colors.green[700], size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Comprova el correu de ${_emailCtrl.text.trim()} i introdueix el codi rebut.',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Codi
        TextField(
          controller: _codeCtrl,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Codi (ex: ABC-123)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            helperText: 'El codi caduca en 15 minuts',
          ),
        ),
        const SizedBox(height: 16),

        // Nova contrasenya
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Nova contrasenya',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            helperText: 'Mínim 8 caràcters',
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Confirmar contrasenya
        TextField(
          controller: _confirmCtrl,
          obscureText: _obscureConfirm,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _loading ? null : _resetPassword(),
          decoration: InputDecoration(
            labelText: 'Confirmar contrasenya',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorText: _error,
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _loading ? null : _resetPassword,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Canviar contrasenya'),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => setState(() { _step = 1; _error = null; }),
            child: const Text('No he rebut el codi — tornar enrere'),
          ),
        ),
      ],
    );
  }

  Widget _buildDone(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Icon(Icons.check_circle_outline, size: 72, color: Colors.green[700]),
        const SizedBox(height: 20),
        Text(
          'Contrasenya actualitzada!',
          style: theme.textTheme.headlineSmall?.copyWith(color: Colors.green[700]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Ja pots entrar a l\'app amb la nova contrasenya.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anar al login'),
          ),
        ),
      ],
    );
  }
}
