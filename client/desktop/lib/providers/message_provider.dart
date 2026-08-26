import 'package:flutter/foundation.dart';

import 'package:ebooking_desktop/models/message_model.dart';
import 'package:ebooking_desktop/services/signalr_service.dart';

class MessageProvider with ChangeNotifier {
  final SignalRService signalRService;

  MessageProvider({required this.signalRService});

  List<ChatGET> _chats = [];
  final Map<String, List<MessageGET>> _messages = {};

  bool _isLoading = false;
  String? _error;

  List<ChatGET> get chats => List.unmodifiable(_chats);
  Map<String, List<MessageGET>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getChats() async {
    _chats = await signalRService.getChats();
    notifyListeners();
  }

  Future<void> getMessages(String chatId) async {
    _messages[chatId] = await signalRService.getMessages(chatId);
    notifyListeners();
  }

  /// Podiže SignalR vezu, povlači razgovore i poruke.
  ///
  /// BUGFIX: ranije je `main.dart` (i `login.dart`, duplirano) radio serijsku
  /// petlju `for (chat in chats) { await getMessages(); await addToChat(); }`.
  /// Kod 20 razgovora to je 40 uzastopnih round-tripova prije nego se prvi
  /// ekran uopšte prikaže. Sada ide paralelno kroz `Future.wait`
  /// (Upute Dodatak A.2).
  Future<void> bootstrap() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await startSignalR();
      await getChats();
      await Future.wait([
        for (final chat in _chats) getMessages(chat.id),
        for (final chat in _chats) addToChat(chat.id),
      ]);
    } catch (e) {
      _error = 'Messenger nije dostupan: veza sa servisom poruka nije '
          'uspostavljena. Ostatak aplikacije radi normalno.';
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

      // BUGFIX: ranije `_messages[data.chatId]!.add(...)` — `!` na mapi koja
      // još nema ključ za taj chat baca `NoSuchMethodError` na null.
      // Dešavalo se svaki put kad stigne poruka u razgovor koji nije bio
      // otvoren u ovoj sesiji.
      _messages.putIfAbsent(data.chatId, () => <MessageGET>[]).add(data);

      for (final chat in _chats) {
        if (chat.id == data.chatId) {
          chat.messages.add(data);
          break;
        }
      }
      notifyListeners();
    });

    signalRService.onReceiveMessage('ReadMessages', (args) {
      if (args == null) return;
      final data = signalRService.handleReadMessages(args);
      if (data == null || data.isEmpty) return;

      final chatId = data.first.chatId;
      final existing = _messages[chatId];
      if (existing != null) {
        for (final message in existing) {
          message.isRead = data.first.isRead;
        }
      }
      for (final chat in _chats) {
        if (chat.id == chatId) {
          chat.messages = data;
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

  Future<void> addToChat(String chatId) async {
    await signalRService.addToChat(chatId);
  }

  Future<void> stopSignalR() => signalRService.stopConnection();

  /// Broj nepročitanih poruka u razgovoru za trenutnog korisnika.
  /// Ranije se ovo računalo u `build()` metodi kroz pomoćnu listu mapa;
  /// ovdje je jedna metoda koju i lista i badge dijele.
  int unreadCount(String chatId, String currentUserId) {
    final chat = _chats.where((c) => c.id == chatId);
    if (chat.isEmpty) return 0;
    return chat.first.messages
        .where((m) => !m.isRead && m.sender != currentUserId)
        .length;
  }

  int totalUnread(String currentUserId) {
    var total = 0;
    for (final chat in _chats) {
      total += unreadCount(chat.id, currentUserId);
    }
    return total;
  }
}
