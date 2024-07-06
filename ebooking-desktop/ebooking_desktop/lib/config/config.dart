class AppConfig {
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'https://ebooking.api.cuteghost.online');
  static const String messengerUrl = String.fromEnvironment('MESSENGER_URL' ,defaultValue: 'https://messenger.cuteghost.online');
}
