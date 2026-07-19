import 'package:ebooking/config/app_theme.dart';
import 'package:ebooking/models/message_model.dart';
import 'package:ebooking/providers/message_provider.dart';
import 'package:ebooking/providers/auth_provider.dart';
import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/widgets/custom_bottom_navigation_bar.dart';
import 'package:ebooking/widgets/custom_partner_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    return FutureBuilder(
      future: Future.wait([
        Provider.of<MessageProvider>(context, listen: false).getChats(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: const Text('Inbox')),
            body: Consumer<MessageProvider>(
              builder: (context, messageProvider, child) {
                final chats = messageProvider.chats;

                if (chats.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'No conversations yet. Messages with hosts show up here.',
                        style: textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: chats.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: AppColors.divider, height: 1, indent: 76),
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    var unread = 0;
                    for (var m in chat.messages) {
                      if (m.isRead == false && m.sender != userId) {
                        unread++;
                      }
                    }
                    final lastMessage = chat.lastMessage?.content ?? '';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.accentTint,
                        child: Icon(
                          PhosphorIcons.user(),
                          color: AppColors.accentLink,
                          size: 20,
                        ),
                      ),
                      title: Text(chat.user2, style: textTheme.titleMedium),
                      subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      ),
                      trailing: unread > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unread',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.bg,
                                ),
                              ),
                            )
                          : Icon(
                              PhosphorIcons.caretRight(),
                              size: 15,
                              color: AppColors.textTertiary,
                            ),
                      onTap: () {
                        Provider.of<MessageProvider>(
                          context,
                          listen: false,
                        ).readMessages(chat.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessengerScreen(
                              contactName: chat.user2,
                              chatId: chat.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            bottomNavigationBar:
                Provider.of<AuthProvider>(context, listen: false).role ==
                    Roles.partner
                ? const CustomPartnerBottomNavigationBar(currentIndex: 2)
                : const CustomBottomNavigationBar(currentIndex: 2),
          );
        }
      },
    );
  }
}

class MessengerScreen extends StatefulWidget {
  final String contactName;
  final String chatId;

  const MessengerScreen({
    super.key,
    required this.contactName,
    required this.chatId,
  });

  @override
  MessengerScreenState createState() => MessengerScreenState();
}

class MessengerScreenState extends State<MessengerScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Future<void> _opening;

  @override
  void initState() {
    super.initState();
    _opening = _open();
  }

  Future<void> _open() => Provider.of<MessageProvider>(
    context,
    listen: false,
  ).openChat(widget.chatId);

  void _retry() {
    setState(() {
      _opening = _open();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    return Consumer<MessageProvider>(
      builder: (context, messageProvider, child) {
        var messages = messageProvider.messages[widget.chatId] ?? [];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });

        void sendMessage() async {
          if (_controller.text.isEmpty) return;

          final messenger = ScaffoldMessenger.of(context);
          try {
            await Provider.of<MessageProvider>(
              context,
              listen: false,
            ).sendMessage(
              MessagePOST(
                content: _controller.text,
                chatId: widget.chatId,
                timeStamp: DateTime.now(),
              ),
            );
            _controller.clear();
          } on StateError catch (error) {
            messenger.showSnackBar(SnackBar(content: Text(error.message)));
          }
        }

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.accentTint,
                  child: Icon(
                    PhosphorIcons.user(),
                    color: AppColors.accentLink,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 11),
                Text(widget.contactName, style: textTheme.titleMedium),
              ],
            ),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: FutureBuilder<void>(
                  future: _opening,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      final error = snapshot.error;
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                error is StateError
                                    ? error.message
                                    : '$error',
                                style: textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _retry,
                                child: const Text('Try again'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    if (messages.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'No messages in this conversation yet.',
                            style: textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        // sender == userId means *this device's user* sent it,
                        // so it belongs on the right -- the opposite of the old
                        // ternary, which put your own messages on the left.
                        final isMine = message.sender == userId;
                        return Align(
                          alignment: isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.74,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: isMine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMine
                                          ? AppColors.accentTint
                                          : AppColors.surface,
                                      border: Border.all(
                                        color: isMine
                                            ? const Color(0xFF423A6A)
                                            : AppColors.border,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(14),
                                        topRight: const Radius.circular(14),
                                        bottomLeft: Radius.circular(
                                          isMine ? 14 : 4,
                                        ),
                                        bottomRight: Radius.circular(
                                          isMine ? 4 : 14,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      message.content,
                                      style: textTheme.bodyLarge?.copyWith(
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        DateFormat(
                                          'HH:mm',
                                        ).format(message.timeStamp),
                                        style: textTheme.bodySmall,
                                      ),
                                      if (isMine) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          message.isRead
                                              ? PhosphorIcons.checks()
                                              : PhosphorIcons.check(),
                                          size: 13,
                                          color: message.isRead
                                              ? AppColors.accent
                                              : AppColors.textTertiary,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Message',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 11,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(99),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(99),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(99),
                              borderSide: const BorderSide(
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          onTap: () {
                            if (_scrollController.hasClients) {
                              _scrollController.jumpTo(
                                _scrollController.position.maxScrollExtent,
                              );
                            }
                            Provider.of<MessageProvider>(
                              context,
                              listen: false,
                            ).readMessages(widget.chatId);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: sendMessage,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(color: AppColors.accent),
                            ),
                          ),
                          child: Icon(
                            PhosphorIcons.paperPlaneTilt(
                              PhosphorIconsStyle.fill,
                            ),
                            size: 17,
                            color: AppColors.accentText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
