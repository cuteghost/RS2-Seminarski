import 'package:ebooking_desktop/models/message_model.dart';
import 'package:ebooking_desktop/providers/message_provider.dart';
import 'package:ebooking_desktop/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:icon_badge/icon_badge.dart';
import 'package:provider/provider.dart';

class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    return FutureBuilder(
      future: Future.wait([
        Provider.of<MessageProvider>(context, listen: false).getChats()
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Messenger'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                List<Map<String, int>> counter = [];
                var chats = messageProvider.chats;
                for (var c in chats) {
                  Map<String, int> countMap = {c.id: 0};
                  for (var m in c.messages) {
                    if (m.isRead == false && m.sender != profile.id) {
                      countMap[c.id] = countMap[c.id]! + 1;
                    }
                  }
                  counter.add(countMap);
                }
                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.blue[100],
                          ),
                          width: 400.0,
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(chats[index].user2),
                            onTap: () {
                              Provider.of<MessageProvider>(context, listen: false)
                                  .readMessages(chats[index].id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessengerScreen(
                                    contactName: chats[index].user2,
                                    chatId: chats[index].id,
                                  ),
                                ),
                              );
                            },
                            trailing: counter[index][chats[index].id] != 0
                                ? IconBadge(
                                    icon: const Icon(Icons.arrow_forward_ios),
                                    itemCount: counter[index][chats[index].id]!,
                                    badgeColor: Colors.red,
                                    itemColor: Colors.white,
                                    maxCount: 99,
                                    hideZero: true,
                                  )
                                : const Icon(Icons.arrow_forward_ios),
                            subtitle: Text(
                              chats[index].messages.isEmpty
                                  ? ''
                                  : chats[index].messages[0].content.length > 11
                                      ? chats[index].messages[0].content.substring(0, 11)
                                      : chats[index].messages[0].content,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                      ],
                    );
                  },
                );
              },
            ),
          );
        }
      },
    );
  }
}

class MessengerScreen extends StatefulWidget {
  final String contactName;
  final String chatId;

  const MessengerScreen({super.key, required this.contactName, required this.chatId});

  @override
  MessengerScreenState createState() => MessengerScreenState();
}

class MessengerScreenState extends State<MessengerScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        var messages = messageProvider.messages[widget.chatId] ?? [];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        void sendMessage() async {
          if (_controller.text.isNotEmpty) {
            await Provider.of<MessageProvider>(context, listen: false).sendMessage(
              MessagePOST(
                content: _controller.text,
                chatId: widget.chatId,
                timeStamp: DateTime.now(),
              ),
            );
            _controller.clear();
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Chat with ${widget.contactName}'),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: messages[index].sender == profile.id
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(8.0),
                                color: messages[index].sender == profile.id
                                    ? Colors.blue[100]
                                    : Colors.green[100],
                              ),
                              width: 200.0,
                              child: ListTile(
                                titleAlignment: ListTileTitleAlignment.top,
                                title: Text(messages[index].content),
                                subtitle: Text(
                                  'Sent: ${messages[index].timeStamp}${messages[index].sender == profile.id ? (messages[index].isRead ? '\r\n\r\nSeen' : '\r\n\r\nSent') : ''}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                        ),
                        onTap: () {
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                          }
                          Provider.of<MessageProvider>(context, listen: false)
                              .readMessages(widget.chatId);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
