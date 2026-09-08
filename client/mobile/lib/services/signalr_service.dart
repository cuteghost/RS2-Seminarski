import 'dart:convert';

import 'package:ebooking/models/message_model.dart';
import 'package:ebooking/services/secure_storage.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:ebooking/config/config.dart' as config;

class SignalRService {
  final HubConnection _hubConnection;
  final SecureStorage secureStorage;

  void Function()? onReconnected;

  static const int _startAttempts = 3;

  SignalRService({required this.secureStorage})
    : _hubConnection = HubConnectionBuilder()
          .withAutomaticReconnect()
          .withUrl(
            '${config.AppConfig.messengerUrl}/chathub',
            HttpConnectionOptions(
              transport: HttpTransportType.webSockets,
              accessTokenFactory: () async =>
                  '${await secureStorage.getToken()}',
            ),
          )
          .build() {
    _hubConnection.onreconnected((connectionId) => onReconnected?.call());
  }

  bool get isConnected => _hubConnection.state == HubConnectionState.connected;

  Future<bool> startConnection() async {
    if (isConnected) return true;

    for (var attempt = 1; attempt <= _startAttempts; attempt++) {
      if (_hubConnection.state != HubConnectionState.disconnected) {
        await stopConnection();
      }
      try {
        await _hubConnection.start();
        return true;
      } catch (_) {
        if (attempt == _startAttempts) return false;
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      }
    }
    return false;
  }

  Future<List<ChatGET>> getChats() async {
    if (!isConnected && !await startConnection()) return [];

    final response = await _hubConnection.invoke('GetChats');
    return (response as List).map((e) => ChatGET.fromJson(e)).toList();
  }

  MessageGET? handleIncommingDriverLocation(List<dynamic>? args) {
    if (args != null) {
      var jsonResponse = json.decode(json.encode(args[0]));
      MessageGET data = MessageGET.fromJson(jsonResponse);
      return data;
    }
    return null;
  }

  List<MessageGET>? handleReadMessages(List<dynamic>? args) {
    if (args != null) {
      var jsonResponse = (args[0] as List).map(
        (e) => json.decode(json.encode(e)),
      );
      List<MessageGET> data = jsonResponse
          .map((e) => MessageGET.fromJson(e))
          .toList();
      return data;
    }
    return null;
  }

  void onReceiveMessage(String methodName, Function(List<dynamic>?) callback) {
    _hubConnection.on(methodName, callback);
  }

  void removeHandlers(String methodName) {
    _hubConnection.off(methodName);
  }

  Future<void> sendMessage(MessagePOST messagePost) async {
    if (!isConnected && !await startConnection()) {
      throw StateError(
        'The messenger is offline, so the message was not sent.',
      );
    }
    await _hubConnection.invoke('SendMessage', args: [messagePost]);
  }

  Future<void> readMessages(String chatId) async {
    if (!isConnected) return;
    await _hubConnection.invoke('ReadMessages', args: [chatId]);
  }

  Future<void> stopConnection() async {
    if (_hubConnection.state == HubConnectionState.disconnected) return;
    await _hubConnection.stop();
  }

  Future<List<MessageGET>> getMessages(String chatId) async {
    if (!isConnected && !await startConnection()) {
      throw StateError(
        'The messenger is offline, so this conversation could not be loaded.',
      );
    }
    final response = await _hubConnection.invoke('GetMessages', args: [chatId]);
    final messages = (response as List)
        .map((e) => MessageGET.fromJson(e))
        .toList();
    messages.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    return messages;
  }

  Future<void> addToChat(String chatId) async {
    if (!isConnected && !await startConnection()) {
      throw StateError(
        'The messenger is offline, so this conversation could not be loaded.',
      );
    }
    await _hubConnection.invoke('AddToChat', args: [chatId]);
  }
}
