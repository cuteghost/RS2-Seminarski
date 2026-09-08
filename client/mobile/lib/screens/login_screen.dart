import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/config/config.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/providers/message_provider.dart';
import 'package:ebooking/providers/profile_provider.dart';
import 'package:ebooking/screens/customer_screens/customer_register_screen.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/screens/partner_screens/my_accommodations_screen.dart';
import 'package:ebooking/utils/navigation_utils.dart';
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
  // Reads a compile-time constant, so it is fixed for the whole build.
  final bool _googleSignInAvailable = AppConfig.isGoogleSignInConfigured;
  final bool _facebookSignInAvailable = AppConfig.isFacebookSignInConfigured;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _signInUnavailableNote {
    if (!_googleSignInAvailable && !_facebookSignInAvailable) {
      return 'Google and Facebook sign-in are unavailable: this build was made '
          'without GOOGLE_SERVER_CLIENT_ID and FACEBOOK_APP_ID.';
    }
    if (!_googleSignInAvailable) {
      return 'Google sign-in is unavailable: this build was made without '
          'GOOGLE_SERVER_CLIENT_ID.';
    }
    return 'Facebook sign-in is unavailable: this build was made without '
        'FACEBOOK_APP_ID.';
  }

  // Shared post-login sequence: identical for email/password, Facebook and
  // Google -- only how `loggedIn` was obtained differs between the three.
  Future<void> _afterSuccessfulLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final String role;
    try {
      role = await authProvider.roleCheck();
      await Future.wait<Object?>([
        messageProvider.loadInitialState(),
        if (role != Roles.partner) profileProvider.getProfile(),
      ]);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.message;
      });
      return;
    }
    if (!mounted) return;

    resetTo(
      context,
      role == Roles.partner
          ? const MyAccommodationsScreen()
          : const DiscoverPropertiesPage(),
    );
  }

  Future<void> _submitEmailLogin() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // The message is the API's own -- a rejected sign-in now says what the
    // server said instead of one sentence for every possible cause.
    final (loggedIn, message) = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    if (loggedIn) {
      await _afterSuccessfulLogin();
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = message;
      });
    }
  }

  Future<void> _submitFacebookLogin() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final (loggedIn, message) = await authProvider.loginWithFacebook();

    if (!mounted) return;
    if (loggedIn) {
      await _afterSuccessfulLogin();
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = message;
      });
    }
  }

  Future<void> _submitGoogleLogin() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final (loggedIn, message) = await authProvider.loginWithGoogle();

    if (!mounted) return;
    if (loggedIn) {
      await _afterSuccessfulLogin();
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = message;
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
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.2,
                    ),
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
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    onSubmitted: (_) =>
                        _isSubmitting ? null : _submitEmailLogin(),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.28),
                        ),
                        borderRadius: BorderRadius.circular(AppColors.radiusMd),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.warningCircle(),
                            size: 16,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.error,
                              ),
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
                        child: Text('OR', style: textTheme.labelSmall),
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
                          // Disabled when the build carries no app id -- the
                          // Facebook SDK then fails natively, which used to
                          // leave this screen spinning forever.
                          onPressed:
                              (_isSubmitting || !_facebookSignInAvailable)
                              ? null
                              : _submitFacebookLogin,
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
                          // Disabled when the build carries no client id --
                          // GoogleSignIn.initialize('') fails inside the plugin
                          // with an error the user cannot act on.
                          onPressed: (_isSubmitting || !_googleSignInAvailable)
                              ? null
                              : _submitGoogleLogin,
                          icon: Icon(PhosphorIcons.googleLogo(), size: 18),
                          label: const Text('Google'),
                        ),
                      ),
                    ],
                  ),
                  if (!_googleSignInAvailable || !_facebookSignInAvailable) ...[
                    const SizedBox(height: 8),
                    Text(
                      _signInUnavailableNote,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 26),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
                                // Pushed so both back buttons land on the
                                // login screen; replacing it left the system
                                // back button closing the app instead.
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CustomerRegisterScreen(),
                                  ),
                                );
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
