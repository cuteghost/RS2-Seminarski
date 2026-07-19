import 'package:flutter/services.dart';

class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:9999',
  );
  static const String messengerUrl = String.fromEnvironment(
    'MESSENGER_URL',
    defaultValue: 'http://10.0.2.2:8888',
  );
  static const String paymentUrl = String.fromEnvironment(
    'PAYMENT_URL',
    defaultValue: 'http://10.0.2.2:9090',
  );
  static const String googleApiKey = String.fromEnvironment(
    'GOOGLE_API_KEY',
    defaultValue: '',
  );

  /// OAuth web client id used by `GoogleSignIn.initialize`. It has no default:
  /// the value that used to sit here was committed to git and has to be
  /// rotated. Pass it at build time, see README.md ("Konfiguracija klijenta").
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  /// False when the build was started without `GOOGLE_SERVER_CLIENT_ID`.
  /// Screens use this to disable Google sign-in instead of letting
  /// `GoogleSignIn.initialize('')` fail with a platform error.
  static bool get isGoogleSignInConfigured => googleServerClientId.isNotEmpty;

  static const String facebookAppId = String.fromEnvironment(
    'FACEBOOK_APP_ID',
    defaultValue: '',
  );

  static bool get isFacebookSignInConfigured => facebookAppId.isNotEmpty;
}

/// The Google key that the Maps SDK already receives, made readable from Dart.
///
/// Gradle reads `google.api.key` out of `android/local.properties` and hands it
/// to the manifest and to `BuildConfig`; the Dart side used to see only
/// `--dart-define=GOOGLE_API_KEY`, so a checkout that set the key in one place
/// had working maps and a geocoder that reported no key at all.
class GoogleConfig {
  static const MethodChannel _channel = MethodChannel('ebooking/local_config');

  static String? _fromPlatform;

  /// `--dart-define=GOOGLE_API_KEY` wins so a build can override the checkout;
  /// otherwise the value Gradle read from `android/local.properties`. Empty
  /// when neither is set, and on platforms that carry no such channel — the
  /// caller turns that into a message rather than a failed request.
  static Future<String> apiKey() async {
    if (AppConfig.googleApiKey.isNotEmpty) return AppConfig.googleApiKey;

    final known = _fromPlatform;
    if (known != null) return known;

    try {
      final value = await _channel.invokeMethod<String>('googleApiKey');
      return _fromPlatform = value ?? '';
    } on MissingPluginException {
      return _fromPlatform = '';
    } on PlatformException {
      return _fromPlatform = '';
    }
  }
}
