import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/providers/message_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/screens/customer_screens/customer_register_screen.dart';
import 'package:ebooking/screens/partner_screens/partner_discover_screen.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/screens/customer_screens/discover_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Shared post-login sequence: identical for email/password, Facebook and
  // Google -- only how `loggedIn` was obtained differs between the three.
  Future<void> _afterSuccessfulLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    await messageProvider.startSignalR();
    await messageProvider.getChats();
    await Future.wait(messageProvider.chats.map((c) async {
      await messageProvider.getMessages(c.id);
      await messageProvider.addToChat(c.id);
    }));
    await profileProvider.getProfile();
    if (!mounted) return;

    final role = await authProvider.roleCheck();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => role == "Customer"
            ? const DiscoverPropertiesPage()
            : const PartnerDiscoverPage(),
      ),
    );
  }

  Future<void> _submitEmailLogin() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loggedIn = await authProvider.login(
        _emailController.text, _passwordController.text);

    if (!mounted) return;
    if (loggedIn == true) {
      await _afterSuccessfulLogin();
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = "That email and password don't match.";
      });
    }
  }

  Future<void> _submitFacebookLogin() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loginWithFacebook();
    final loggedIn = await authProvider.checkLoggedInStatus();

    if (!mounted) return;
    if (loggedIn == true) {
      await _afterSuccessfulLogin();
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = "Facebook login failed. Please try again.";
      });
    }
  }

  Future<void> _submitGoogleLogin() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loginWithGoogle();
    final loggedIn = await authProvider.checkLoggedInStatus();

    if (!mounted) return;
    if (loggedIn == true) {
      await _afterSuccessfulLogin();
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = "Google login failed. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero photo, clipped so the following content overlaps its
            // bottom ~96px (mirrors the mockup's negative margin-top).
            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 264 / 360,
                child: SizedBox(
                  height: 360,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/Image.jpeg',
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 200,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.bg,
                                AppColors.bg.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find your stay',
                    style: textTheme.headlineMedium?.copyWith(fontSize: 34),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search and book your perfect stay.',
                    style: textTheme.bodyLarge
                        ?.copyWith(color: AppColors.textSecondary, height: 1.2),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? PhosphorIcons.eye()
                              : PhosphorIcons.eyeSlash(),
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    onSubmitted: (_) =>
                        _isSubmitting ? null : _submitEmailLogin(),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.28)),
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                      ),
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.warningCircle(),
                              size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: textTheme.bodySmall
                                  ?.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : _submitEmailLogin,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Continue'),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.divider)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: textTheme.labelSmall,
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.divider)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.text,
                            side: const BorderSide(color: AppColors.border),
                          ),
                          onPressed:
                              _isSubmitting ? null : _submitFacebookLogin,
                          icon: Icon(PhosphorIcons.facebookLogo(), size: 18),
                          label: const Text('Facebook'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.text,
                            side: const BorderSide(color: AppColors.border),
                          ),
                          onPressed: _isSubmitting ? null : _submitGoogleLogin,
                          icon: Icon(PhosphorIcons.googleLogo(), size: 18),
                          label: const Text('Google'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                        children: [
                          const TextSpan(text: 'New here? '),
                          TextSpan(
                            text: 'Create an account',
                            style: const TextStyle(
                              color: AppColors.accentLink,
                              fontWeight: FontWeight.w500,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CustomerRegisterScreen()));
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
