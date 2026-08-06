import 'package:dio/dio.dart';
import 'package:femcastells/core/navigation/route_names.dart';
import 'package:femcastells/core/network/dio_factory.dart';
import 'package:femcastells/features/login/login.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';
import 'package:femcastells/l10n/app_localizations.dart';

const _storage = FlutterSecureStorage();
const _kEmail = 'saved_email';
const _kPassword = 'saved_password';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final email    = await _storage.read(key: _kEmail);
    final password = await _storage.read(key: _kPassword);
    if (email != null && mounted) {
      _emailCtrl.text = email;
      context.read<LoginFormBloc>().add(LoginMailChanged(email));
    }
    if (password != null && mounted) {
      _passwordCtrl.text = password;
      context.read<LoginFormBloc>().add(LoginPasswordChanged(password));
    }
  }

  Future<void> _saveCredentials(LoginFormState state) async {
    await _storage.write(key: _kEmail,    value: state.mail.value);
    await _storage.write(key: _kPassword, value: state.password.value);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;

    return BlocListener<LoginFormBloc, LoginFormState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          _saveCredentials(state);
        }
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(translate.loginSnackBarError)),
            );
          context.read<LoginFormBloc>().add(const LoginResetStatus());
        }
      },
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            translate.loginPageTitle,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _MailInput(controller: _emailCtrl),
                          const SizedBox(height: 12),
                          _PasswordInput(controller: _passwordCtrl),
                          const SizedBox(height: 16),
                          _LoginButton(),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () => context.push(forgotPasswordRoute),
                            child: const Text('Has oblidat la contrasenya?'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DemoSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoSection extends StatefulWidget {
  @override
  State<_DemoSection> createState() => _DemoSectionState();
}

class _DemoSectionState extends State<_DemoSection> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure  = true;
  bool _accepted = false;
  bool _loading  = false;

  bool get _canSubmit {
    final email = _emailCtrl.text.trim();
    final pw    = _passwordCtrl.text;
    return email.contains('@') && email.length > 4 && pw.length >= 8 && _accepted && !_loading;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _enterDemo() async {
    setState(() => _loading = true);
    try {
      final response = await DioFactory.getInstance().post('/api/demo/register', data: {
        'email':    _emailCtrl.text.trim().toLowerCase(),
        'password': _passwordCtrl.text,
      });
      final token = response.data['access_token'] as String;
      if (!mounted) return;
      await context.read<AuthenticationRepository>().loginWithToken(token);
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?['message'] ?? 'Error en accedir a la demo.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Prova la demo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Correu electrònic',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Contrasenya (mínim 8 caràcters)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              isDense: true,
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 2),
          CheckboxListTile(
            value: _accepted,
            onChanged: (v) => setState(() => _accepted = v ?? false),
            title: const Text(
              'Accepto accedir a dades de demostració',
              style: TextStyle(fontSize: 12),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _canSubmit ? _enterDemo : null,
              icon: _loading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Prova la demo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MailInput extends StatelessWidget {
  final TextEditingController controller;
  const _MailInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final isError =
        context.select((LoginFormBloc b) => b.state.mail.displayError) != null;
    return TextField(
      key: const Key('loginForm_mailInput_textField'),
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      onChanged: (mail) =>
          context.read<LoginFormBloc>().add(LoginMailChanged(mail)),
      decoration: InputDecoration(
        labelText: translate.loginPageEmailTitle,
        errorText: isError ? translate.loginPageInvalidMail : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordInput({required this.controller});

  @override
  State<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<_PasswordInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final isError = context.select(
          (LoginFormBloc bloc) => bloc.state.password.displayError,
        ) !=
        null;
    return TextField(
      key: const Key('loginForm_passwordInput_textField'),
      controller: widget.controller,
      onChanged: (password) =>
          context.read<LoginFormBloc>().add(LoginPasswordChanged(password)),
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: translate.loginPagePasswordTitle,
        errorText: isError ? translate.loginPageInvalidPassword : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context)!;
    final isInProgressOrSuccess = context.select(
      (LoginFormBloc bloc) => bloc.state.status.isInProgressOrSuccess,
    );

    if (isInProgressOrSuccess) {
      EasyLoading.show(status: 'Loading...');
    } else {
      EasyLoading.dismiss();
    }

    final isValid =
        context.select((LoginFormBloc bloc) => bloc.state.isValid);

    return ElevatedButton(
      key: const Key('loginForm_continue_raisedButton'),
      onPressed: isValid
          ? () => context.read<LoginFormBloc>().add(const LoginSubmitted())
          : null,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(translate.loginPageLoginButton),
    );
  }
}
