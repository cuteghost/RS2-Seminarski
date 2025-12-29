import 'package:ebooking_desktop/models/message_model.dart';
import 'package:ebooking_desktop/providers/auth_provider.dart';
import 'package:ebooking_desktop/providers/message_provider.dart';
import 'package:ebooking_desktop/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:icon_badge/icon_badge.dart';
import 'package:provider/provider.dart';

class ContactListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    return FutureBuilder(
      future: Future.wait([
        Provider.of<MessageProvider>(context, listen: false).getChats()
      ]), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('Messenger'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ),
            body: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                List<Map<String, int>> counter = [];
                var chats = messageProvider.chats;
                chats.forEach((c) {
                  Map<String, int> countMap = {c.Id: 0};
                  c.Messages.forEach((m) {
                    if (m.IsRead == false && m.Sender != profile.id) {
                      countMap[c.Id] = countMap[c.Id]! + 1;
                    }
                  });
                  counter.add(countMap);
                });
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
                            leading: Icon(Icons.person),
                            title: Text(chats[index].User2),
                            onTap: () {
                              Provider.of<MessageProvider>(context, listen: false).readMessages(chats[index].Id);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessengerScreen(
                                      contactName: chats[index].User2,
                                      chatId: chats[index].Id,
                                    ),
                                ),
                              );
                            },
                            trailing: counter[index][chats[index].Id] != 0 ? IconBadge(icon: Icon(Icons.arrow_forward_ios), itemCount: counter[index][chats[index].Id]!, badgeColor: Colors.red, itemColor: Colors.white, maxCount: 99, hideZero: true) : Icon(Icons.arrow_forward_ios),
                            subtitle: Text('${chats[index].Messages.isEmpty 
                                        ? '' 
                                        : chats[index].Messages[0].Content.length > 11 
                                          ? chats[index].Messages[0].Content.substring(0, 11) 
                                          : chats[index].Messages[0].Content}'),
                          ),
                        ),
                        SizedBox(height: 10.0)
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
  MessengerScreen({required this.contactName, required this.chatId});

  @override
  _MessengerScreenState createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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
        void _sendMessage() async{
          if (_controller.text.isNotEmpty) {
            await Provider.of<MessageProvider>(context, listen: false).sendMessage(
              MessagePOST(
                Content: _controller.text,
                ChatId: widget.chatId,
                TimeStamp: DateTime.now()
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
                      children: [
                        Column(
                          children: [
                            Container(
                              child: ListTile(
                                title: Text(messages[index].Content),
                                titleAlignment: ListTileTitleAlignment.top,
                                subtitle: Text('Sent: ${messages[index].TimeStamp.toString()}${messages[index].Sender == profile.id ?(messages[index].IsRead ? '\r\n\r\nSeen' : '\r\n\r\nSent'): ''}', style: TextStyle(color: Colors.grey, fontSize: 12.0)),
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(8.0),
                                color: messages[index].Sender == profile.id ? Colors.blue[100] : Colors.green[100],
                              ),
                              width: 200.0,
                            ),
                            SizedBox(height: 10.0)
                          ],
                        ),
                      ],
                      mainAxisAlignment: messages[index].Sender == profile.id
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
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
                        decoration: InputDecoration(
                          hintText: 'Type a message',
                        ),
                        onTap: () {
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                          }
                          Provider.of<MessageProvider>(context, listen: false).readMessages(widget.chatId);
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        
      }
    );
  }
}
    