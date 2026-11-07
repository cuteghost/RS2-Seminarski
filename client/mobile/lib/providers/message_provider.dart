import 'package:flutter/material.dart';
import 'package:ebooking/models/message_model.dart';
import 'package:ebooking/services/signalr_service.dart';

class MessageProvider with ChangeNotifier {
  final SignalRService signalRService;

  List<ChatGET> _chats = [];
  final Map<String, List<MessageGET>> _messages = {};
  final Map<String, int> _loadedPage = {};
  final Map<String, bool> _hasMore = {};
  final Set<String> _loadingOlder = {};

  List<ChatGET> get chats => _chats;
  Map<String, List<MessageGET>> get messages => _messages;

  int get unreadCount => _chats.fold(0, (sum, chat) => sum + chat.unreadCount);

  bool hasOlderMessages(String chatId) => _hasMore[chatId] ?? false;

  bool isLoadingOlder(String chatId) => _loadingOlder.contains(chatId);

  String? _connectionError;

  String? get connectionError => _connectionError;

  MessageProvider({required this.signalRService}) {
    signalRService.onReconnected = _refresh;
  }

  Future<void> _refresh() async {
    _connectionError = null;
    await getChats();
  }

  Future<void> getChats() async {
    _chats = await signalRService.getChats();
    notifyListeners();
  }

  Future<void> getMessages(String chatId) async {
    final page = await signalRService.getMessages(chatId);
    _messages[chatId] = page.items;
    _loadedPage[chatId] = page.page;
    _hasMore[chatId] = page.hasMore;
    notifyListeners();
  }

  Future<void> loadOlderMessages(String chatId) async {
    if (_loadingOlder.contains(chatId) || !hasOlderMessages(chatId)) return;
    _loadingOlder.add(chatId);
    notifyListeners();
    try {
      final next = (_loadedPage[chatId] ?? 1) + 1;
      final page = await signalRService.getMessages(chatId, page: next);
      _messages[chatId] = [...page.items, ...?_messages[chatId]];
      _loadedPage[chatId] = page.page;
      _hasMore[chatId] = page.hasMore;
    } finally {
      _loadingOlder.remove(chatId);
      notifyListeners();
    }
  }

  ChatGET? _chat(String chatId) {
    for (final chat in _chats) {
      if (chat.id == chatId) return chat;
    }
    return null;
  }

  Future<bool> startSignalR() async {
    final connected = await signalRService.startConnection();
    if (!connected) return false;

    signalRService.removeHandlers('ReceiveMessage');
    signalRService.removeHandlers('ReadMessages');

    signalRService.onReceiveMessage('ReceiveMessage', (args) {
      if (args == null) return;
      final data = signalRService.handleIncomingMessage(args);
      if (data == null) return;

      _messages[data.chatId]?.add(data);

      final chat = _chat(data.chatId);
      if (chat == null) {
        getChats();
        return;
      }
      chat.lastMessage = data;
      if (!data.isCurrent && !data.isRead) chat.unreadCount++;
      _chats.sort(
        (a, b) => (b.lastMessage?.timeStamp ?? DateTime(0)).compareTo(
          a.lastMessage?.timeStamp ?? DateTime(0),
        ),
      );
      notifyListeners();
    });
    signalRService.onReceiveMessage('ReadMessages', (args) {
      if (args == null) return;
      final data = signalRService.handleReadMessages(args);
      if (data == null || data.isEmpty) return;

      final chatId = data[0].chatId;
      for (final message in _messages[chatId] ?? const <MessageGET>[]) {
        if (message.isCurrent) message.isRead = true;
      }
      final last = _chat(chatId)?.lastMessage;
      if (last != null && last.isCurrent) last.isRead = true;
      notifyListeners();
    });
    return true;
  }

  /// Everything the messenger needs right after sign-in: the connection and
  /// the conversation list. Each list entry already carries its latest
  /// message and unread count, so no conversation is loaded until opened.
  Future<void> loadInitialState() async {
    if (!await startSignalR()) {
      _connectionError =
          'The messenger is not reachable right now. Your chats will load once it is back.';
      notifyListeners();
      return;
    }

    _connectionError = null;
    await getChats();
  }

  Future<void> openChat(String chatId) async {
    await getMessages(chatId);
    await readMessages(chatId);
  }

  Future<void> sendMessage(MessagePOST messagePost) async {
    await signalRService.sendMessage(messagePost);
  }

  Future<void> readMessages(String chatId) async {
    await signalRService.readMessages(chatId);
    final chat = _chat(chatId);
    if (chat != null && chat.unreadCount > 0) {
      chat.unreadCount = 0;
      notifyListeners();
    }
  }

  Future<void> stopSignalR() async {
    await signalRService.stopConnection();
  }

  Future<void> clear() async {
    _chats = [];
    _messages.clear();
    _loadedPage.clear();
    _hasMore.clear();
    _connectionError = null;
    notifyListeners();
    await stopSignalR();
  }
}
