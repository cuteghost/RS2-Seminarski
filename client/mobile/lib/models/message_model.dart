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
    return {
      'content': content,
      'timeStamp': DateTime.now().toIso8601String(),
      'chatId': chatId,
    };
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
      timeStamp: DateTime.parse(json['timeStamp']),
      isRead: json['isRead'],
      chatId: json['chatId'],
      isCurrent: json['isCurrent'],
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
  final String user1;
  final String user2;
  List<MessageGET> messages;

  ChatGET({
    required this.id,
    required this.user1,
    required this.user2,
    required this.messages,
  });

  factory ChatGET.fromJson(Map<String, dynamic> json) {
    final messages = (json['messages'] as List)
        .map((e) => MessageGET.fromJson(e))
        .toList();
    messages.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
    return ChatGET(
      id: json['id'],
      user1: json['user1'],
      user2: json['user2'],
      messages: messages,
    );
  }

  MessageGET? get lastMessage => messages.isEmpty ? null : messages.last;
}
