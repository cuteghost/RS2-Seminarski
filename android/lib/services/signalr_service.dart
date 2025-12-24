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
            .withUrl('${config.AppConfig.messengerUrl}/chathub', HttpConnectionOptions(
              transport: HttpTransportType.webSockets,
              accessTokenFactory: () async => '${await secureStorage.getToken()}',
              logging: (level, message) => print('SIGNALR -> $message'),
            ))
            .build();

  Future<void> startConnection() async {
    try {
      await _hubConnection.start();
      print('Connection started');
    } catch (e) {
      print('Error starting connection: $e');
      if (e.toString().contains('Cannot start a HubConnection that is not in the \'Disconnected\' state.')) {
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
      print('Error getting chats: $e');
      if (e.toString().contains('Cannot send data if the connection is not in the \'Connected\' State.')) {
        await startConnection();
        return await getChats();
      }
      return [];
    }
  }
  List<MessageGET>? handleReadMessages(List<dynamic>? args) {
    if (args!=null) {
      var jsonResponse = (args[0] as List).map((e) => json.decode(json.encode(e)));
      List<MessageGET> data = jsonResponse.map((e) => MessageGET.fromJson(e)).toList();
      return data;
    }
    return null;
  }

  void onReceiveMessage(String methodName,Function(List<dynamic>?) callback) {
    _hubConnection.on(methodName, callback);
  }

  Future<void> sendMessage(MessagePOST messagePost) async {
    if (_hubConnection.state == HubConnectionState.connected) {
      try {
        await _hubConnection.invoke('SendMessage', args: [messagePost]);
      } catch (e) {
        print('Error sending message: $e');
      }
    } else {
      print('Cannot send message. Not connected.');
    }
  }
  Future<void> readMessages(String chatId) async {
    if (_hubConnection.state == HubConnectionState.connected) {
      try {
        await _hubConnection.invoke('ReadMessages', args: [chatId]);
      } catch (e) {
        print('Error sending message: $e');
      }
    } else {
      print('Cannot send message. Not connected.');
    }
  }

  Future<void> stopConnection() async {
    try {
      if (_hubConnection.state == HubConnectionState.connected || _hubConnection.state == HubConnectionState.connecting) {
        await _hubConnection.stop();
        print('Connection stopped');
      } else {
        print('Connection is already in state: ${_hubConnection.state}');
      }
    } catch (e) {
      print('Error stopping connection: $e');
    }
  }
  
  MessageGET? handleIncommingDriverLocation(List<dynamic>? args) {
    if (args!=null) {
      var jsonResponse = json.decode(json.encode(args[0]));
      MessageGET data = MessageGET.fromJson(jsonResponse);
      return data;
    }
    return null;
  }

  Future<List<MessageGET>> getMessages(String chatId) async{
    final response =  await _hubConnection.invoke('GetMessages', args: [chatId]);
    return (response as List).map((e) => MessageGET.fromJson(e)).toList();
  }

  Future<void> addToChat(String chatId) async {
    await _hubConnection.invoke('AddToChat', args: [chatId]);
  }
}