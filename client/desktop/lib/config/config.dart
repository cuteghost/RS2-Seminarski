class AppConfig {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:9999');
  static const String messengerUrl = String.fromEnvironment('MESSENGER_URL' ,defaultValue: 'http://localhost:8888');
  static const String geocoderUrl = String.fromEnvironment('GEOCODER_URL', defaultValue: 'https://nominatim.openstreetmap.org');
}
