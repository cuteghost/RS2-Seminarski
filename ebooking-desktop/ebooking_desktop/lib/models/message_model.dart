class MessagePOST {
  final String Content;
  final DateTime TimeStamp;
  final String ChatId;

  MessagePOST({
    required this.Content,
    required this.TimeStamp,
    required this.ChatId,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': Content,
      'timeStamp': DateTime.now().toIso8601String(),
      'chatId': ChatId,
    };
  }
}

class MessageGET {
  final String Sender;
  final String Content;
  final DateTime TimeStamp;
  bool IsRead;
  final String ChatId;
  final bool IsCurrent;

  MessageGET({
    required this.Sender,
    required this.Content,
    required this.TimeStamp,
    required this.IsRead,
    required this.ChatId,
    required this.IsCurrent,
  });
  
  factory MessageGET.fromJson(Map<String, dynamic> json) {
    return MessageGET(
      Sender: json['senderId'],
      Content: json['content'],
      TimeStamp: DateTime.parse(json['timeStamp']),
      IsRead: json['isRead'],
      ChatId: json['chatId'],
      IsCurrent: json['isCurrent'],
    );
  }
}

class ChatPOST {
  final String User2;

  ChatPOST({
    required this.User2,
  });

  Map<String, dynamic> toJson() {
    return {
      'user2Id': User2,
    };
  
  }
}
class ChatGET {
  final String Id;
  final String User1;
  final String User2;
  List<MessageGET> Messages;

  ChatGET({
    required this.Id,
    required this.User1,
    required this.User2,
    required this.Messages,
  });

  factory ChatGET.fromJson(Map<String, dynamic> json) {
    return ChatGET(
      Id: json['id'],
      User1: json['user1'],
      User2: json['user2'],
      Messages: (json['messages'] as List).map((e) => MessageGET.fromJson(e)).toList(),
    );
  }
}