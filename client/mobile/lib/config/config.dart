class AppConfig {
  static const String baseUrl =
      String.fromEnvironment('BASE_URL', defaultValue: 'http://10.0.2.2:9999');
  static const String googleApiKey =
      String.fromEnvironment('GOOGLE_API_KEY', defaultValue: '');
  static const String messengerUrl = String.fromEnvironment('MESSENGER_URL',
      defaultValue: 'http://10.0.2.2:8888');
  static const String paymentUrl = String.fromEnvironment('PAYMENT_URL',
      defaultValue: 'http://10.0.2.2:6666');

  static void validateConfig() {
    if (googleApiKey.isEmpty) {
      throw Exception(
          'GOOGLE_API_KEY must be provided via --dart-define=GOOGLE_API_KEY=your_key');
    }
  }
}
