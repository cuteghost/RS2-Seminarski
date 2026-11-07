import 'package:flutter/foundation.dart';

import 'package:ebooking_desktop/models/message_model.dart';
import 'package:ebooking_desktop/services/signalr_service.dart';

class MessageProvider with ChangeNotifier {
  final SignalRService signalRService;

  MessageProvider({required this.signalRService});

  List<ChatGET> _chats = [];
  final Map<String, List<MessageGET>> _messages = {};
  final Map<String, int> _loadedPage = {};
  final Map<String, bool> _hasMore = {};
  final Set<String> _loadingOlder = {};

  bool hasOlderMessages(String chatId) => _hasMore[chatId] ?? false;

  bool isLoadingOlder(String chatId) => _loadingOlder.contains(chatId);

  bool _isLoading = false;
  String? _error;
  String? _pendingChatId;

  List<ChatGET> get chats => List.unmodifiable(_chats);
  Map<String, List<MessageGET>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => signalRService.isConnected;

  /// Postavlja se kad je razgovor otvoren van ekrana *Poruke* (npr. iz reda
  /// tabele *Korisnici*). `MessengerPage` ga preuzme kroz [consumePendingChatId]
  /// čim postane vidljiv i odabere taj razgovor.
  String? get pendingChatId => _pendingChatId;

  String? consumePendingChatId() {
    final id = _pendingChatId;
    _pendingChatId = null;
    return id;
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

  Future<void> openChat(String chatId) async {
    await getMessages(chatId);
    await readMessages(chatId);
  }

  ChatGET? _chat(String chatId) {
    for (final chat in _chats) {
      if (chat.id == chatId) return chat;
    }
    return null;
  }

  Future<void> bootstrap() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await startSignalR();
      await getChats();
    } catch (e) {
      _error = 'Messenger is unavailable: could not connect to the messaging '
          'service. The rest of the application works normally.';
      if (kDebugMode) {
        debugPrint('MessageProvider.bootstrap: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startSignalR() async {
    await signalRService.startConnection();

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
      notifyListeners();
    });

    signalRService.onReceiveMessage('ReadMessages', (args) {
      if (args == null) return;
      final data = signalRService.handleReadMessages(args);
      if (data == null || data.isEmpty) return;

      final chatId = data.first.chatId;
      for (final message in _messages[chatId] ?? const <MessageGET>[]) {
        if (message.isCurrent) message.isRead = true;
      }
      final last = _chat(chatId)?.lastMessage;
      if (last != null && last.isCurrent) last.isRead = true;
      notifyListeners();
    });
  }

  Future<void> sendMessage(MessagePOST messagePost) async {
    await signalRService.sendMessage(messagePost);
    notifyListeners();
  }

  Future<void> readMessages(String chatId) async {
    await signalRService.readMessages(chatId);
    final chat = _chat(chatId);
    if (chat != null) chat.unreadCount = 0;
    notifyListeners();
  }

  /// Otvara (ili kreira) razgovor sa datim korisnikom i priprema ga da bude
  /// odabran čim se prikaže ekran *Poruke*.
  Future<void> openChatWithUser(String otherUserId) async {
    if (!signalRService.isConnected) {
      await startSignalR();
    }

    final chat = await signalRService.openChat(otherUserId);

    final existingIndex = _chats.indexWhere((c) => c.id == chat.id);
    if (existingIndex >= 0) {
      _chats[existingIndex] = chat;
    } else {
      _chats.add(chat);
    }

    _pendingChatId = chat.id;
    notifyListeners();
  }

  Future<void> stopSignalR() => signalRService.stopConnection();

  int unreadCount(String chatId, String currentUserId) =>
      _chat(chatId)?.unreadCount ?? 0;

  int totalUnread(String currentUserId) =>
      _chats.fold(0, (sum, chat) => sum + chat.unreadCount);
}
