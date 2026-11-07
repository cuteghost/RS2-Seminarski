import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const int codeLength = 6;
  static const int minimumPasswordLength = 8;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController = TextEditingController(
    text: widget.initialEmail,
  );
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _codeSent = false;
  bool _busy = false;
  String? _info;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  Future<void> _sendCode() async {
    if (_validateEmail(_emailController.text) != null) {
      _formKey.currentState?.validate();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final message = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).requestPasswordReset(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _codeSent = true;
        _info = message;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final message = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).resetPassword(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop(_emailController.text.trim());
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _codeSent
                      ? 'Enter the 6-digit code from the email and choose a new password.'
                      : 'Enter the email of your account. We will send you a one-time code that is valid for 15 minutes.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  enabled: !_codeSent && !_busy,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: _validateEmail,
                ),
                if (_codeSent) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: codeLength,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Code'),
                    validator: (value) => (value ?? '').trim().length != codeLength
                        ? 'The code has $codeLength digits'
                        : null,
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New password',
                    ),
                    validator: (value) =>
                        (value ?? '').length < minimumPasswordLength
                        ? 'Use at least $minimumPasswordLength characters'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Repeat new password',
                    ),
                    validator: (value) => value != _passwordController.text
                        ? 'The passwords do not match'
                        : null,
                  ),
                ],
                if (_info != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _info!,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.accentText,
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _busy ? null : (_codeSent ? _reset : _sendCode),
                  child: _busy
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_codeSent ? 'Change password' : 'Send code'),
                ),
                if (_codeSent)
                  TextButton(
                    onPressed: _busy ? null : _sendCode,
                    child: const Text('Send a new code'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
