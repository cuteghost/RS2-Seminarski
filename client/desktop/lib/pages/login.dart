import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/providers/auth_provider.dart';
import 'package:ebooking_desktop/providers/location_provider.dart';
import 'package:ebooking_desktop/providers/message_provider.dart';
import 'package:ebooking_desktop/providers/profile_provider.dart';
import 'package:ebooking_desktop/providers/reference_data_provider.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

/// Prijava — split layout iz `eBooking Support Console.dc.html`:
/// lijevo brand panel sa akcentnim radijalnim gradijentom, desno forma.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _formError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_isSubmitting) return;
    setState(() => _formError = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final admin = context.read<AdminProvider>();
    final profile = context.read<ProfileProvider>();
    final messages = context.read<MessageProvider>();
    final locations = context.read<LocationProvider>();
    final reference = context.read<ReferenceDataProvider>();
    final navigator = Navigator.of(context);

    try {
      final result = await auth.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!result.success) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _formError = result.message;
        });
        return;
      }

      // Rola se čita iz tokena koji je potpisao server, ne postavlja je klijent.
      final role = await auth.roleCheck();
      if (role != 'Administrator') {
        await auth.logout();
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _formError = 'This account does not have administrator privileges. '
              'The desktop application is intended for administrators only.';
        });
        return;
      }

      // Podaci se povlače paralelno. Messenger se namjerno NE čeka blokirajuće
      // preko `Future.wait` sa ostatkom — ako Messenger mikroservis nije
      // podignut, prijava i dalje mora proći (ostatak aplikacije radi).
      await Future.wait([
        profile.getProfile(),
        admin.loadAll(),
        locations.loadAll(),
        reference.loadAll(),
      ]);
      unawaitedBootstrap(messages);

      if (!mounted) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AppShell()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _formError = 'Login succeeded, but loading data failed. '
            'Check whether all services are running.';
      });
    }
  }

  /// Namjerno bez `await` — Messenger se podiže u pozadini.
  void unawaitedBootstrap(MessageProvider messages) {
    messages.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Expanded(flex: 44, child: _BrandPanel()),
          Expanded(
            flex: 56,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpace.x8),
                child: SizedBox(width: 340, child: _buildForm(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Log in', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpace.x2),
          Text(
            'Access is granted to administrator accounts only.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpace.x8),

          NField(
            label: 'E-mail',
            child: TextFormField(
              controller: _emailController,
              autofocus: true,
              enabled: !_isSubmitting,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(hintText: 'ime@edu.fit.ba'),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Enter an email address.';
                final regex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
                if (!regex.hasMatch(text)) {
                  return 'Enter a valid email address in the format: name@domain.ba';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: AppSpace.x4),

          NField(
            label: 'Password',
            child: TextFormField(
              controller: _passwordController,
              enabled: !_isSubmitting,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _signIn(),
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? 'Show password'
                      : 'Hide password',
                  icon: Icon(
                    _obscurePassword
                        ? PhosphorIcons.eye()
                        : PhosphorIcons.eyeSlash(),
                    size: 16,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter a password.';
                }
                return null;
              },
            ),
          ),

          if (_formError != null) ...[
            const SizedBox(height: AppSpace.x4),
            _FormError(message: _formError!),
          ],

          const SizedBox(height: AppSpace.x8),
          OutlinedButton(
            onPressed: _isSubmitting ? null : _signIn,
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Log in'),
          ),
        ],
      ),
    );
  }
}

class _FormError extends StatelessWidget {
  final String message;
  const _FormError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppColors.radiusMd),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIcons.warningCircle(), size: 15, color: AppColors.error),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lijevi panel. Dizajn: `radial-gradient(120% 90% at 15% 15%,
/// var(--color-accent-900) 0%, var(--color-bg) 60%)`.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.7, -0.7),
          radius: 1.2,
          colors: [AppColors.accentTint, AppColors.bg],
          stops: [0.0, 0.6],
        ),
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.all(AppSpace.x12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accent),
                  borderRadius: BorderRadius.circular(AppColors.radiusSm),
                ),
                child: Icon(PhosphorIcons.house(),
                    size: 16, color: AppColors.accent),
              ),
              const SizedBox(width: 10),
              Text('eBooking', style: theme.textTheme.titleMedium),
            ],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Administrator\nconsole',
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpace.x4),
                Text(
                  'Properties, users, reference data, reports and '
                  'customer communication — all in one place.',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const _BrandStats(),
        ],
      ),
    );
  }
}

/// Prije prijave nema autorizovanog pristupa podacima, pa se prikazuje neutralna napomena
/// umjesto hardkodiranih brojeva.
class _BrandStats extends StatelessWidget {
  const _BrandStats();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(PhosphorIcons.shieldCheck(), size: 15, color: AppColors.textTertiary),
        const SizedBox(width: AppSpace.x3),
        Expanded(
          child: Text(
            'The connection is authorized with a JWT token. All operations are logged on the server.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontSize: 12, color: AppColors.textTertiary),
          ),
        ),
      ],
    );
  }
}
