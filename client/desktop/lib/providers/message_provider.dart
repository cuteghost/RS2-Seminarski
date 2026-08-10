import 'package:flutter/material.dart';
import 'package:ebooking_desktop/models/message_model.dart';
import 'package:ebooking_desktop/services/signalr_service.dart';

class MessageProvider with ChangeNotifier {
  final SignalRService signalRService;

  List<ChatGET> _chats = [];
  final Map<String, List<MessageGET>> _messages = {};

  List<ChatGET> get chats => _chats;
  Map<String, List<MessageGET>> get messages => _messages;

  MessageProvider({required this.signalRService});

  Future<void> getChats() async {
    _chats = await signalRService.getChats();
    notifyListeners();
  }

  Future<void> getMessages(String chatId) async {
    _messages[chatId] = await signalRService.getMessages(chatId);
    notifyListeners();
  }

  Future<void> startSignalR() async {
    await signalRService.startConnection();
    signalRService.onReceiveMessage('ReceiveMessage', (args) {
      if (args == null) return;
      final data = signalRService.handleIncommingDriverLocation(args);
      _messages[data!.chatId]!.add(data);
      for (var c in chats) {
        if (c.id == data.chatId) {
          c.messages.add(data);
          break;
        }
      }
      notifyListeners();
    });
    signalRService.onReceiveMessage('ReadMessages', (args) {
      if (args == null) return;
      final data = signalRService.handleReadMessages(args);

      if (_messages[data![0].chatId] == null) return;
      for (var i = 0; i < _messages[data[0].chatId]!.length; i++) {
        _messages[data[0].chatId]![i].isRead = data[0].isRead;
      }
      for (var c in chats) {
        if (c.id == data[0].chatId) {
          c.messages = data;
          break;
        }
      }
      notifyListeners();
    });
  }

  Future<void> sendMessage(MessagePOST messagePost) async {
    await signalRService.sendMessage(messagePost);
    notifyListeners();
  }

  Future<void> readMessages(String chatId) async {
    await signalRService.readMessages(chatId);
    notifyListeners();
  }

  Future<void> stopSignalR() async {
    await signalRService.stopConnection();
  }

  Future<void> addToChat(String chatId) async {
    await signalRService.addToChat(chatId);
    notifyListeners();
  }
}
