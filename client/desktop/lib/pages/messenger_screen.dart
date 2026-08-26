import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:provider/provider.dart';

import 'package:ebooking_desktop/config/app_theme.dart';
import 'package:ebooking_desktop/models/message_model.dart';
import 'package:ebooking_desktop/providers/message_provider.dart';
import 'package:ebooking_desktop/providers/profile_provider.dart';
import 'package:ebooking_desktop/widgets/nocturne.dart';

/// Poruke — dvopanelni prikaz iz dizajna: lista razgovora lijevo, razgovor desno.
///
/// Izmjene u odnosu na staru verziju (`ContactListScreen` + `MessengerScreen`):
///  - Bila su DVA ekrana sa `Navigator.push` između njih; na desktopu to znači
///    da administrator gubi listu razgovora čim otvori jedan. Dizajn traži
///    jedan ekran sa dva panela.
///  - `ContactListScreen` je u `build()`-u pravio `FutureBuilder` koji je na
///    SVAKI rebuild ponovo zvao `getChats()` — beskonačna petlja poziva.
///  - `messages[0]` je prikazivan kao pretpregled (najstarija poruka), skraćen
///    ručnim `substring(0, 11)` — što baca `RangeError` kod višebajtnih znakova
///    i pravi "..." usred slova. Sada zadnja poruka + `TextOverflow.ellipsis`.
///  - `Row(mainAxisAlignment: sender == profile.id ? start : end)` je stavljao
///    VLASTITE poruke lijevo, a tuđe desno — obrnuto od svake poznate
///    messaging konvencije.
///  - Nije bilo `dispose()` za `TextEditingController` u `ContactListScreen`.
///  - `_scrollController.jumpTo(...)` je pozivan u `addPostFrameCallback` na
///    svaki rebuild, pa se lista nije mogla skrolati unazad — svaki novi frame
///    bi je vratio na dno. Sada se skrola samo kad stigne nova poruka.
class MessengerPage extends StatefulWidget {
  const MessengerPage({super.key});

  @override
  State<MessengerPage> createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  final _searchController = TextEditingController();
  final _draftController = TextEditingController();
  final _scrollController = ScrollController();

  String? _activeChatId;
  String _query = '';
  bool _sending = false;
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _draftController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottomIfNeeded(int messageCount) {
    if (messageCount == _lastMessageCount) return;
    _lastMessageCount = messageCount;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _selectChat(String chatId) async {
    setState(() {
      _activeChatId = chatId;
      _lastMessageCount = 0;
    });
    _draftController.clear();
    await context.read<MessageProvider>().readMessages(chatId);
  }

  Future<void> _send() async {
    final text = _draftController.text.trim();
    final chatId = _activeChatId;
    if (text.isEmpty || chatId == null || _sending) return;

    setState(() => _sending = true);
    final provider = context.read<MessageProvider>();

    try {
      await provider.sendMessage(
        MessagePOST(
          content: text,
          chatId: chatId,
          timeStamp: DateTime.now().toUtc(),
        ),
      );
      _draftController.clear();
    } catch (e) {
      if (!mounted) return;
      // BUGFIX: ranije je neuspjelo slanje bilo tiho progutano u servisu —
      // input bi se ispraznio i poruka bi nestala bez traga.
      nToast(
        context,
        'Poruka nije poslana. Provjerite vezu sa servisom poruka '
        'i pokušajte ponovo.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MessageProvider, ProfileProvider>(
      builder: (context, messages, profileProvider, _) {
        final currentUserId = profileProvider.profile.id;

        if (messages.isLoading && messages.chats.isEmpty) {
          return const Center(child: NLoading(label: 'Povezivanje…'));
        }

        if (messages.error != null && messages.chats.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSpace.x8),
            child: NErrorState(
              message: messages.error!,
              onRetry: messages.bootstrap,
            ),
          );
        }

        final chats = messages.chats.where((chat) {
          if (_query.isEmpty) return true;
          return chat.user2.toLowerCase().contains(_query.toLowerCase());
        }).toList();

        // Razgovori sa najnovijom porukom idu na vrh.
        chats.sort((a, b) {
          final aTime = a.lastMessage?.timeStamp;
          final bTime = b.lastMessage?.timeStamp;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        ChatGET? activeChat;
        if (_activeChatId != null) {
          for (final chat in messages.chats) {
            if (chat.id == _activeChatId) {
              activeChat = chat;
              break;
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.all(AppSpace.x8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppColors.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: _ChatList(
                    chats: chats,
                    activeChatId: _activeChatId,
                    currentUserId: currentUserId,
                    searchController: _searchController,
                    onSearch: (value) => setState(() => _query = value),
                    unreadOf: (chatId) =>
                        messages.unreadCount(chatId, currentUserId),
                    onSelect: _selectChat,
                  ),
                ),
                const VerticalDivider(width: 1, color: AppColors.border),
                Expanded(
                  child: activeChat == null
                      ? const _NoChatSelected()
                      : Builder(
                          builder: (context) {
                            final thread =
                                messages.messages[activeChat!.id] ?? const [];
                            // BUGFIX: ovo se ranije zvalo IZ `build()`-a
                            // widgeta `_ChatThread` — dijete je mijenjalo
                            // stanje roditelja i zakazivalo novi frame usred
                            // gradnje stabla, što je u kombinaciji sa
                            // IndexedStack-om davalo beskonačnu kaskadu
                            // render grešaka. Sada je poziv u vlasništvu
                            // ovog Statea.
                            _scrollToBottomIfNeeded(thread.length);
                            return _ChatThread(
                              chat: activeChat!,
                              messages: thread,
                              currentUserId: currentUserId,
                              scrollController: _scrollController,
                              draftController: _draftController,
                              sending: _sending,
                              onSend: _send,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChatList extends StatelessWidget {
  final List<ChatGET> chats;
  final String? activeChatId;
  final String currentUserId;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final int Function(String chatId) unreadOf;
  final void Function(String chatId) onSelect;

  const _ChatList({
    required this.chats,
    required this.activeChatId,
    required this.currentUserId,
    required this.searchController,
    required this.onSearch,
    required this.unreadOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.x4),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Poruke', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpace.x3),
                NSearchField(
                  controller: searchController,
                  hint: 'Pretraga razgovora',
                  onChanged: onSearch,
                ),
              ],
            ),
          ),
          Expanded(
            child: chats.isEmpty
                ? const NEmptyState(
                    message: 'Nema aktivnih razgovora.',
                  )
                : ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      return _ChatListTile(
                        chat: chat,
                        active: chat.id == activeChatId,
                        unread: unreadOf(chat.id),
                        onTap: () => onSelect(chat.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChatListTile extends StatefulWidget {
  final ChatGET chat;
  final bool active;
  final int unread;
  final VoidCallback onTap;

  const _ChatListTile({
    required this.chat,
    required this.active,
    required this.unread,
    required this.onTap,
  });

  @override
  State<_ChatListTile> createState() => _ChatListTileState();
}

class _ChatListTileState extends State<_ChatListTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final last = widget.chat.lastMessage;
    final timeFormat = DateFormat('HH:mm');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.x4, vertical: AppSpace.x4),
          decoration: BoxDecoration(
            color: widget.active
                ? AppColors.neutral800
                : (_hovered
                    ? AppColors.text.withValues(alpha: 0.04)
                    : Colors.transparent),
            border: Border(
              bottom: BorderSide(color: AppColors.divider),
              left: BorderSide(
                width: 2,
                color: widget.active ? AppColors.accent : Colors.transparent,
              ),
            ),
          ),
          child: Row(
            children: [
              NInitialsAvatar(name: widget.chat.user2, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.chat.user2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        if (last != null)
                          Text(
                            timeFormat.format(last.timeStamp),
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            last?.content ?? 'Nema poruka',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 12),
                          ),
                        ),
                        if (widget.unread > 0) ...[
                          const SizedBox(width: AppSpace.x2),
                          NTag('${widget.unread}', variant: NTagVariant.accent),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoChatSelected extends StatelessWidget {
  const _NoChatSelected();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NEmptyState(
        icon: PhosphorIcons.chatCircle(),
        message: 'Odaberite razgovor sa liste da vidite poruke.',
      ),
    );
  }
}

class _ChatThread extends StatelessWidget {
  final ChatGET chat;
  final List<MessageGET> messages;
  final String currentUserId;
  final ScrollController scrollController;
  final TextEditingController draftController;
  final bool sending;
  final VoidCallback onSend;

  const _ChatThread({
    required this.chat,
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
    required this.draftController,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy. HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpace.x4),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              NInitialsAvatar(name: chat.user2, size: 32),
              const SizedBox(width: AppSpace.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(chat.user2,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${messages.length} poruka u razgovoru',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: messages.isEmpty
              ? const NEmptyState(
                  message: 'Razgovor je prazan. Pošaljite prvu poruku.',
                )
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpace.x6),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.sender == currentUserId;
                    return _MessageBubble(
                      message: message,
                      isMine: isMine,
                      timestampLabel: dateFormat.format(message.timeStamp),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpace.x4),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: draftController,
                  enabled: !sending,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: 'Napišite poruku…',
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.x3),
              SizedBox(
                height: 38,
                child: OutlinedButton(
                  onPressed: sending ? null : onSend,
                  child: sending
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(PhosphorIcons.paperPlaneTilt(), size: 16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageGET message;
  final bool isMine;
  final String timestampLabel;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.timestampLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.x4),
      child: Row(
        // BUGFIX: vlastite poruke desno, sagovornikove lijevo.
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.32,
            ),
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        isMine ? AppColors.accentTint : AppColors.neutral800,
                    borderRadius: BorderRadius.circular(AppColors.radiusMd),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13.5,
                      height: 1.5,
                      color: isMine ? AppColors.accentText : AppColors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timestampLabel,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 10.5,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 5),
                      Icon(
                        message.isRead
                            ? PhosphorIcons.checks()
                            : PhosphorIcons.check(),
                        size: 11,
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
        ],
      ),
    );
  }
}
