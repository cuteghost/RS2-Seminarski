/// The server stores `DateTime.UtcNow` and serialises it without an offset,
/// so a bare timestamp is UTC and has to be marked as such before `toLocal()`.
DateTime? _parseServerUtc(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final hasOffset = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(raw);
  return DateTime.tryParse(hasOffset ? raw : '${raw}Z')?.toLocal();
}

class MessagePOST {
  final String content;
  final DateTime timeStamp;
  final String chatId;

  const MessagePOST({
    required this.content,
    required this.timeStamp,
    required this.chatId,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'chatId': chatId,
      };
}

class MessageGET {
  final String sender;
  final String content;
  final DateTime timeStamp;
  bool isRead;
  final String chatId;
  final bool isCurrent;

  MessageGET({
    required this.sender,
    required this.content,
    required this.timeStamp,
    required this.isRead,
    required this.chatId,
    required this.isCurrent,
  });

  factory MessageGET.fromJson(Map<String, dynamic> json) {
    return MessageGET(
      sender: json['senderId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      timeStamp: _parseServerUtc(json['timeStamp']?.toString()) ?? DateTime.now(),
      isRead: json['isRead'] == true,
      chatId: json['chatId']?.toString() ?? '',
      isCurrent: json['isCurrent'] == true,
    );
  }
}

class ChatPOST {
  final String user2;

  const ChatPOST({required this.user2});

  Map<String, dynamic> toJson() => {'user2Id': user2};
}

class MessagePage {
  final List<MessageGET> items;
  final int page;
  final bool hasMore;

  const MessagePage({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  factory MessagePage.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => MessageGET.fromJson(
                e.map((k, v) => MapEntry(k.toString(), v))))
            .toList()
        : <MessageGET>[];
    items.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    return MessagePage(
      items: items,
      page: (json['page'] as num?)?.toInt() ?? 1,
      hasMore: json['hasMore'] == true,
    );
  }
}

class ChatGET {
  final String id;
  final String user1Id;
  final String user2Id;
  final String user1;
  final String user2;
  MessageGET? lastMessage;
  int unreadCount;

  ChatGET({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.user1,
    required this.user2,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory ChatGET.fromJson(Map<String, dynamic> json) {
    final last = json['lastMessage'];
    return ChatGET(
      id: json['id']?.toString() ?? '',
      user1Id: json['user1Id']?.toString() ?? '',
      user2Id: json['user2Id']?.toString() ?? '',
      user1: json['user1']?.toString() ?? '',
      user2: json['user2']?.toString() ?? '',
      lastMessage: last is Map
          ? MessageGET.fromJson(last.map((k, v) => MapEntry(k.toString(), v)))
          : null,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}
