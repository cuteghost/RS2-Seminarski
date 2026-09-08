import 'package:flutter/material.dart';
import 'package:ebooking/models/message_model.dart';
import 'package:ebooking/services/signalr_service.dart';

class MessageProvider with ChangeNotifier {
  final SignalRService signalRService;

  List<ChatGET> _chats = [];
  final Map<String, List<MessageGET>> _messages = {};

  List<ChatGET> get chats => _chats;
  Map<String, List<MessageGET>> get messages => _messages;

  String? _connectionError;

  String? get connectionError => _connectionError;

  MessageProvider({required this.signalRService}) {
    signalRService.onReconnected = _rejoin;
  }

  Future<void> _rejoin() async {
    _connectionError = null;
    await getChats();
    await Future.wait(_chats.map((c) => addToChat(c.id)));
  }

  Future<void> getChats() async {
    _chats = await signalRService.getChats();
    notifyListeners();
  }

  Future<void> getMessages(String chatId) async {
    _messages[chatId] = await signalRService.getMessages(chatId);
    notifyListeners();
  }

  Future<bool> startSignalR() async {
    final connected = await signalRService.startConnection();
    if (!connected) return false;

    signalRService.removeHandlers('ReceiveMessage');
    signalRService.removeHandlers('ReadMessages');

    signalRService.onReceiveMessage('ReceiveMessage', (args) {
      if (args == null) return;
      final data = signalRService.handleIncommingDriverLocation(args);
      if (data == null) return;
      _messages.putIfAbsent(data.chatId, () => <MessageGET>[]).add(data);
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
      if (data == null || data.isEmpty) return;

      final chatId = data[0].chatId;
      final ordered = List<MessageGET>.from(data)
        ..sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
      _messages[chatId] = ordered;
      for (var c in chats) {
        if (c.id == chatId) {
          c.messages = List<MessageGET>.from(ordered);
          break;
        }
      }
      notifyListeners();
    });
    return true;
  }

  /// Everything the messenger needs right after sign-in.
  ///
  /// These are all hub invocations, so the order is forced: the connection
  /// has to be up before the chat list can be asked for, and the chat list
  /// has to exist before its messages can. Within one chat list the fetches
  /// run together. Callers should run this next to their own independent
  /// work rather than in front of it.
  Future<void> loadInitialState() async {
    if (!await startSignalR()) {
      _connectionError =
          'The messenger is not reachable right now. Your chats will load once it is back.';
      notifyListeners();
      return;
    }

    _connectionError = null;
    await getChats();
    await Future.wait(
      _chats.map((c) async {
        await getMessages(c.id);
        await addToChat(c.id);
      }),
    );
  }

  Future<void> openChat(String chatId) async {
    await addToChat(chatId);
    await getMessages(chatId);
    await readMessages(chatId);
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

  Future<void> clear() async {
    _chats = [];
    _messages.clear();
    _connectionError = null;
    notifyListeners();
    await stopSignalR();
  }

  Future<void> addToChat(String chatId) async {
    await signalRService.addToChat(chatId);
    notifyListeners();
  }
}
