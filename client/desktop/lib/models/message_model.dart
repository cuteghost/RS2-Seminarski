class MessagePOST {
  final String content;
  final DateTime timeStamp;
  final String chatId;

  const MessagePOST({
    required this.content,
    required this.timeStamp,
    required this.chatId,
  });

  /// BUGFIX: raniji `toJson` je ignorisao proslijeđeni `timeStamp` i uvijek
  /// slao `DateTime.now()`. Sada šalje ono što mu je dato, i to u UTC —
  /// Upute Dodatak A.4 traže standardizaciju na UTC kroz cijelu aplikaciju
  /// jer se u Docker okruženju lokalna zona kontejnera razlikuje od hosta.
  Map<String, dynamic> toJson() => {
        'content': content,
        'timeStamp': timeStamp.toUtc().toIso8601String(),
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
      timeStamp:
          DateTime.tryParse(json['timeStamp']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
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
    final rawMessages = json['messages'];
    return ChatGET(
      id: json['id']?.toString() ?? '',
      user1: json['user1']?.toString() ?? '',
      user2: json['user2']?.toString() ?? '',
      messages: rawMessages is List
          ? rawMessages
              .whereType<Map>()
              .map((e) => MessageGET.fromJson(
                  e.map((k, v) => MapEntry(k.toString(), v))))
              .toList()
          : <MessageGET>[],
    );
  }

  /// Zadnja poruka u razgovoru — za pretpregled u listi.
  /// BUGFIX: stari ekran je prikazivao `messages[0]` (NAJSTARIJU poruku)
  /// i sjekao je na 11 znakova preko `substring`. Sada je zadnja poruka,
  /// a skraćivanje radi `TextOverflow.ellipsis` u widgetu.
  MessageGET? get lastMessage => messages.isEmpty ? null : messages.last;
}
