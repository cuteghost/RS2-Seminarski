class AppConfig {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:9999');
  static const String messengerUrl = String.fromEnvironment('MESSENGER_URL' ,defaultValue: 'http://localhost:8888');
}
