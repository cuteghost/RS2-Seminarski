class AppConfig {
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'https://ebooking.api.cuteghost.online');
  static const String googleApiKey = String.fromEnvironment('GOOGLE_API_KEY', defaultValue: 'AIzaSyCrqJoPPUE5MMBKwhOpcpbybGMwuZfD1KQ');
  static const String messengerUrl = String.fromEnvironment('MESSENGER_URL', defaultValue: 'https://messenger.cuteghost.online');
  static const String paymentUrl = String.fromEnvironment('PAYMENT_URL', defaultValue: 'https://payment.cuteghost.online');
}
