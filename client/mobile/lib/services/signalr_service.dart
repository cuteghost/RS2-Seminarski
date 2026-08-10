import 'dart:convert';

import 'package:ebooking/models/message_model.dart';
import 'package:ebooking/services/auth_service.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:ebooking/config/config.dart' as config;

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
                      '${await secureStorage.getToken()}',
                ))
            .build();

  Future<void> startConnection() async {
    try {
      await _hubConnection.start();
    } catch (e) {
      if (e.toString().contains(
          'Cannot start a HubConnection that is not in the \'Disconnected\' state.')) {
        await stopConnection();
        await startConnection();
      }
    }
  }

  Future<List<ChatGET>> getChats() async {
    try {
      final response = await _hubConnection.invoke('GetChats');
      return (response as List).map((e) => ChatGET.fromJson(e)).toList();
    } catch (e) {
      if (e.toString().contains(
          'Cannot send data if the connection is not in the \'Connected\' State.')) {
        await startConnection();
        return await getChats();
      }
      return [];
    }
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
      var jsonResponse =
          (args[0] as List).map((e) => json.decode(json.encode(e)));
      List<MessageGET> data =
          jsonResponse.map((e) => MessageGET.fromJson(e)).toList();
      return data;
    }
    return null;
  }

  void onReceiveMessage(String methodName, Function(List<dynamic>?) callback) {
    _hubConnection.on(methodName, callback);
  }

  Future<void> sendMessage(MessagePOST messagePost) async {
    if (_hubConnection.state == HubConnectionState.connected) {
      try {
        await _hubConnection.invoke('SendMessage', args: [messagePost]);
      } catch (e) {
        // Ignore send errors — SignalR will retry on reconnect
      }
    } else {
      // Not connected — message dropped; caller should handle reconnection
    }
  }

  Future<void> readMessages(String chatId) async {
    if (_hubConnection.state == HubConnectionState.connected) {
      try {
        await _hubConnection.invoke('ReadMessages', args: [chatId]);
      } catch (e) {
        // Ignore read-receipt errors — non-critical
      }
    } else {
      // Not connected — read receipt skipped
    }
  }

  Future<void> stopConnection() async {
    try {
      if (_hubConnection.state == HubConnectionState.connected ||
          _hubConnection.state == HubConnectionState.connecting) {
        await _hubConnection.stop();
      } else {
        // Already stopped or in an intermediate state — nothing to do
      }
    } catch (e) {
      // Ignore stop errors — connection will be cleaned up by GC
    }
  }

  Future<List<MessageGET>> getMessages(String chatId) async {
    final response = await _hubConnection.invoke('GetMessages', args: [chatId]);
    return (response as List).map((e) => MessageGET.fromJson(e)).toList();
  }

  Future<void> addToChat(String chatId) async {
    await _hubConnection.invoke('AddToChat', args: [chatId]);
  }
}
