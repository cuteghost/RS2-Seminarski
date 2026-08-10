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
    defaultValue: 'http://10.0.2.2:6666',
  );
  static const String googleApiKey = String.fromEnvironment(
    'GOOGLE_API_KEY',
    defaultValue: '',
  );
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '29969402007-rrhvn645jvpelod7s187o7flse02u87h.apps.googleusercontent.com',
  );
}
