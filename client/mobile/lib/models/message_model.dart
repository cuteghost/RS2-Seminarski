import 'package:ebooking/utils/server_time.dart';

class MessagePOST {
  final String content;
  final DateTime timeStamp;
  final String chatId;

  const MessagePOST({
    required this.content,
    required this.timeStamp,
    required this.chatId,
  });

  Map<String, dynamic> toJson() {
    return {'content': content, 'chatId': chatId};
  }
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
      sender: json['senderId'],
      content: json['content'],
      timeStamp: parseServerUtc(json['timeStamp'] as String),
      isRead: json['isRead'],
      chatId: json['chatId'],
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }
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
    final items = (json['items'] as List? ?? const [])
        .map((e) => MessageGET.fromJson(e as Map<String, dynamic>))
        .toList();
    items.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    return MessagePage(
      items: items,
      page: (json['page'] as num?)?.toInt() ?? 1,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}

class ChatPOST {
  final String user2;

  const ChatPOST({required this.user2});

  Map<String, dynamic> toJson() {
    return {'user2Id': user2};
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
      id: json['id'],
      user1Id: json['user1Id'] as String? ?? '',
      user2Id: json['user2Id'] as String? ?? '',
      user1: json['user1'] as String? ?? '',
      user2: json['user2'] as String? ?? '',
      lastMessage: last == null
          ? null
          : MessageGET.fromJson(last as Map<String, dynamic>),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}
