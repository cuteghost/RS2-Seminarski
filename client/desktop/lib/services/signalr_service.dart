import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:signalr_core/signalr_core.dart';

import 'package:ebooking_desktop/config/config.dart' as config;
import 'package:ebooking_desktop/models/message_model.dart';
import 'package:ebooking_desktop/services/auth_service.dart';

/// SignalR klijent za Messenger mikroservis.
///
/// PREIMENOVANO: `handleIncommingDriverLocation` -> `handleIncomingMessage`.
/// Stari naziv je bio copy-paste ostatak iz nepovezanog taksi projekta
/// (isti izvor kao `TaxiHDbContext` namespace na backendu) i sadržavao je i
/// pravopisnu grešku. Upute 8.1: "Potrebno je ispraviti greške u nazivima
/// klasa i datoteka; ne ostavljati copy-paste ostatke iz drugih projekata."
class SignalRService {
  final HubConnection _hubConnection;
  final SecureStorage secureStorage;

  SignalRService({required this.secureStorage})
      : _hubConnection = HubConnectionBuilder()
            .withAutomaticReconnect()
            .withUrl(
              '${config.AppConfig.messengerUrl}/chathub',
              HttpConnectionOptions(
                transport: HttpTransportType.webSockets,
                accessTokenFactory: () async =>
                    await secureStorage.getToken() ?? '',
              ),
            )
            .build();

  bool get isConnected => _hubConnection.state == HubConnectionState.connected;

  /// Broj pokušaja ponovnog povezivanja unutar `startConnection`.
  /// Ranije je `catch` blok rekurzivno zvao `startConnection()` bez ikakvog
  /// brojača — jedan trajni kvar veze pravio je beskonačnu rekurziju.
  static const _maxStartAttempts = 3;

  Future<void> startConnection({int attempt = 1}) async {
    if (isConnected) return;
    try {
      await _hubConnection.start();
    } catch (e) {
      final isWrongState = e.toString().contains(
          "Cannot start a HubConnection that is not in the 'Disconnected' state.");

      if (isWrongState && attempt < _maxStartAttempts) {
        await stopConnection();
        await startConnection(attempt: attempt + 1);
        return;
      }
      // Upute Dodatak A.1: "Error handling je obavezan; worker ne smije tiho
      // postati nedostupan bez logiranja razloga." Isto vrijedi i za klijenta —
      // greška se propagira naviše da je provider može prikazati.
      rethrow;
    }
  }

  Future<List<ChatGET>> getChats({int attempt = 1}) async {
    try {
      final response = await _hubConnection.invoke('GetChats');
      if (response is! List) return const [];
      return response
          .map((e) => ChatGET.fromJson(_asMap(e)))
          .toList();
    } catch (e) {
      final notConnected = e.toString().contains(
          "Cannot send data if the connection is not in the 'Connected' State.");
      if (notConnected && attempt < _maxStartAttempts) {
        await startConnection();
        return getChats(attempt: attempt + 1);
      }
      rethrow;
    }
  }

  Future<List<MessageGET>> getMessages(String chatId) async {
    final response = await _hubConnection.invoke('GetMessages', args: [chatId]);
    if (response is! List) return const [];
    return response.map((e) => MessageGET.fromJson(_asMap(e))).toList();
  }

  Future<void> sendMessage(MessagePOST messagePost) async {
    if (!isConnected) {
      await startConnection();
    }
    // BUGFIX: raniji `catch (e) { }` je tiho gutao neuspjelo slanje — poruka
    // bi nestala, a korisnik bi vidio prazan input kao da je poslana.
    await _hubConnection.invoke('SendMessage', args: [messagePost]);
  }

  Future<void> readMessages(String chatId) async {
    if (!isConnected) return;
    try {
      await _hubConnection.invoke('ReadMessages', args: [chatId]);
    } catch (e) {
      // Potvrda čitanja nije kritična — ne rušimo tok, ali logiramo.
      if (kDebugMode) debugPrint('SignalRService.readMessages: $e');
    }
  }

  Future<void> addToChat(String chatId) async {
    await _hubConnection.invoke('AddToChat', args: [chatId]);
  }

  Future<void> stopConnection() async {
    try {
      final state = _hubConnection.state;
      if (state == HubConnectionState.connected ||
          state == HubConnectionState.connecting) {
        await _hubConnection.stop();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('SignalRService.stopConnection: $e');
    }
  }

  void onReceiveMessage(String methodName, void Function(List<dynamic>?) callback) {
    _hubConnection.on(methodName, callback);
  }

  MessageGET? handleIncomingMessage(List<dynamic>? args) {
    if (args == null || args.isEmpty) return null;
    try {
      return MessageGET.fromJson(_asMap(args[0]));
    } catch (e) {
      if (kDebugMode) debugPrint('SignalRService.handleIncomingMessage: $e');
      return null;
    }
  }

  List<MessageGET>? handleReadMessages(List<dynamic>? args) {
    if (args == null || args.isEmpty) return null;
    final payload = args[0];
    if (payload is! List) return null;
    try {
      return payload.map((e) => MessageGET.fromJson(_asMap(e))).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('SignalRService.handleReadMessages: $e');
      return null;
    }
  }

  /// SignalR vraća `Map<dynamic, dynamic>`; normalizujemo u `Map<String, dynamic>`.
  /// Ranije se to radilo preko `json.decode(json.encode(e))` — dvostruka
  /// serijalizacija po poruci, bez potrebe.
  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    if (value is String) {
      final decoded = json.decode(value);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    }
    return const {};
  }
}
