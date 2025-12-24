class AppConfig {
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://10.0.2.2:9999');
  static const String googleApiKey = String.fromEnvironment('GOOGLE_API_KEY', defaultValue: 'AIzaSyCrqJoPPUE5MMBKwhOpcpbybGMwuZfD1KQ');
  static const String messengerUrl = String.fromEnvironment('MESSENGER_URL', defaultValue: 'http://10.0.2.2:8888');
  static const String paymentUrl = String.fromEnvironment('PAYMENT_URL', defaultValue: 'http://10.0.2.2:6666');
}
