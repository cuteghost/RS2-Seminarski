import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/providers/admin_provider.dart';
import 'package:ebooking_desktop/providers/auth_provider.dart';
import 'package:ebooking_desktop/providers/location_provider.dart';
import 'package:ebooking_desktop/providers/message_provider.dart';
import 'package:ebooking_desktop/providers/profile_provider.dart';
import 'package:ebooking_desktop/widgets/app_shell.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

/// Prijava — split layout iz `eBooking Support Console.dc.html`:
/// lijevo brand panel sa akcentnim radijalnim gradijentom, desno forma.
///
/// Izmjene u odnosu na staru verziju:
///  - Bio je `StatelessWidget` sa `TextEditingController`-ima kao poljima
///    instance koji se NIKAD nisu `dispose`-ovali (curenje memorije).
///  - Nije bilo `Form` / validacije — prazan submit je slao HTTP zahtjev.
///  - Nije bilo loading stanja — dvoklik je slao dva login zahtjeva.
///  - Na neuspjeh je radio samo `return;` — korisnik nije dobijao poruku.
///  - Lozinka se nije mogla otkriti, nema submit na Enter.
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

      // Upute 5: klijent ne smije sam sebi dodijeliti privilegije. Rola se
      // čita iz tokena koji je potpisao server; desktop je administratorski
      // klijent pa svaka druga rola ovdje nema šta tražiti.
      final role = await auth.roleCheck();
      if (role != 'Administrator') {
        await auth.logout();
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _formError = 'Ovaj nalog nema administratorska ovlaštenja. '
              'Desktop aplikacija je namijenjena isključivo administratorima.';
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
        _formError = 'Prijava je uspjela, ali učitavanje podataka nije. '
            'Provjerite da li su svi servisi pokrenuti.';
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
          Text('Prijava', style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpace.x2),
          Text(
            'Pristup je dozvoljen isključivo administratorskim nalozima.',
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
              // Upute 4: poruka mora navesti format, ne generičko "Invalid".
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Unesite e-mail adresu.';
                final regex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
                if (!regex.hasMatch(text)) {
                  return 'Unesite ispravnu e-mail adresu u formatu: ime@domena.ba';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: AppSpace.x4),

          NField(
            label: 'Lozinka',
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
                      ? 'Prikaži lozinku'
                      : 'Sakrij lozinku',
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
                  return 'Unesite lozinku.';
                }
                return null;
              },
            ),
          ),

          // Upute 4: validacijske poruke se prikazuju ispod kontrola,
          // ne kao dijalog i ne unutar input polja.
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
                : const Text('Prijavi se'),
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
/// var(--color-accent-900) 0%, var(--color-bg) 60%)` — akcenat kao sjaj,
/// nikad kao ispuna (readme.md: "the accent carries its chroma in lines
/// and marks, never as a flood").
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
                  'Administratorska\nkonzola',
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpace.x4),
                Text(
                  'Smještaji, korisnici, referentni podaci, izvještaji i '
                  'komunikacija sa klijentima — na jednom mjestu.',
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

/// Brojevi na login ekranu dolaze iz podataka nakon prijave; prije prijave
/// nemamo autorizovan pristup pa se prikazuje neutralna napomena umjesto
/// izmišljenih brojeva. (Dizajn ovdje pokazuje 1.248 / 86 / 31 — to su
/// mock vrijednosti iz prototipa i namjerno se NE hardkodiraju.)
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
            'Veza je autorizovana JWT tokenom. Sve operacije se bilježe na serveru.',
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
