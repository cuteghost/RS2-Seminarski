using Authentication.Services.TokenHandlerService;
using AutoMapper;
using Database;
using Messenger.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Models.DTO.MessengerDTO;
using System.Security.Claims;

namespace Messenger;

[Authorize]
public class ChatHub : Hub, IChatHub
{
    private readonly IMapper _mapper;
    private readonly IServiceScopeFactory _serviceScopeFactory;


    public ChatHub(IMapper mapper, IServiceScopeFactory serviceScopeFactory)
    {
        _mapper = mapper;
        _serviceScopeFactory = serviceScopeFactory;
    }

    public async Task AddToChat(string chatId)
    {
        await RequireParticipant(chatId);
        await Groups.AddToGroupAsync(Context.ConnectionId, chatId);
    }

    public async Task SendMessage(MessagePOST messageDto)
    {
        var userId = await RequireParticipant(messageDto.ChatId.ToString());
        messageDto.SenderId = userId;

        var message = _mapper.Map<Message>(messageDto);

        using var scope = _serviceScopeFactory.CreateScope();
        var messageRepository = scope.ServiceProvider.GetRequiredService<IMessageRepository>();

        messageRepository.Add(message);
        MessageGET messageGET = _mapper.Map<MessageGET>(message);
        messageGET.isCurrent = false;
        var chatId = message.ChatId.ToString();

        await Clients.Group(chatId).SendAsync("ReceiveMessage", messageGET);
    }

    public async Task<List<ChatGET>> GetChats()
    {
        var userId = await RequireValidCaller();

        using var scope = _serviceScopeFactory.CreateScope();
        var messageRepository = scope.ServiceProvider.GetRequiredService<IMessageRepository>();
        var chats = await messageRepository.GetChatsAsync(userId);
        return chats.Select(chat => MapChat(chat, userId)).ToList();
    }

    public async Task<ChatGET> OpenChat(Guid otherUserId)
    {
        var userId = await RequireValidCaller();

        if (otherUserId == userId)
            throw new HubException("You cannot open a conversation with yourself.");

        using var scope = _serviceScopeFactory.CreateScope();
        var messageRepository = scope.ServiceProvider.GetRequiredService<IMessageRepository>();

        var chat = await messageRepository.GetOrCreateChatAsync(userId, otherUserId);
        if (chat == null)
            throw new HubException($"User with identifier {otherUserId} does not exist.");

        return MapChat(chat, userId);
    }

    private ChatGET MapChat(Chat chat, Guid callerId)
    {
        var isFirst = chat.User1Id == callerId;
        return new ChatGET
        {
            Id = chat.Id,
            User1Id = isFirst ? chat.User1Id : chat.User2Id,
            User2Id = isFirst ? chat.User2Id : chat.User1Id,
            User1 = isFirst ? chat.User1.DisplayName : chat.User2.DisplayName,
            User2 = isFirst ? chat.User2.DisplayName : chat.User1.DisplayName,
            Messages = _mapper.Map<List<MessageGET>>(chat.Messages.OrderByDescending(m => m.Timestamp))
        };
    }

    public async Task InitChat(string chatId)
    {
        await RequireParticipant(chatId);
        await Groups.AddToGroupAsync(Context.ConnectionId, chatId);
    }


    public async Task<List<MessageGET>> GetMessages(string chatId)
    {
        var userId = await RequireParticipant(chatId);

        using var scope = _serviceScopeFactory.CreateScope();
        var messageRepository = scope.ServiceProvider.GetRequiredService<IMessageRepository>();
        var messages = _mapper.Map<List<MessageGET>>(await messageRepository.GetMessagesAsync(chatId));
        foreach (var m in messages)
        {
            m.isCurrent = m.SenderId == userId;
        }
        return messages;
    }

    public async Task ReadMessages(string chatId)
    {
        var userId = await RequireParticipant(chatId);

        using var scope = _serviceScopeFactory.CreateScope();
        var messageRepository = scope.ServiceProvider.GetRequiredService<IMessageRepository>();
        var messages = await messageRepository.ReadMessages(chatId, userId);
        await Clients.Group(chatId).SendAsync("ReadMessages", _mapper.Map<List<MessageGET>>(messages));
    }

    public async Task AddToGroup(string chatId)
    {
        await RequireParticipant(chatId);
        await Groups.AddToGroupAsync(Context.ConnectionId, chatId);
    }

    public async Task RemoveFromGroup(string chatId)
    {
        await RequireParticipant(chatId);
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, chatId);
    }

    private async Task<Guid> RequireValidCaller()
    {
        var principal = Context.User;

        var purpose = principal?.FindFirst(TokenHandlerService.PurposeClaim)?.Value;
        if (!string.IsNullOrEmpty(purpose))
            return Reject("A payment ticket does not open conversations. Please log in to the app.");

        var rawUserId = principal?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var rawVersion = principal?.FindFirst(TokenHandlerService.TokenVersionClaim)?.Value;

        if (!Guid.TryParse(rawUserId, out var userId) || !int.TryParse(rawVersion, out var version))
            return Reject("The token was issued before server-side logout was introduced. Please log in again.");

        using var scope = _serviceScopeFactory.CreateScope();
        var tokenHandlerService = scope.ServiceProvider.GetRequiredService<ITokenHandlerService>();

        if (!await tokenHandlerService.IsTokenVersionValid(userId, version))
            return Reject("The token was revoked by logout or the account no longer exists. Please log in again.");

        return userId;
    }

    /// <summary>
    /// Authenticates the caller and then checks that the conversation is actually theirs.
    /// <see cref="RequireValidCaller"/> alone only proves the token is valid, so without this
    /// any logged in user could read, mark read or write into any chat by guessing its id.
    /// Must run before anything is returned or the connection joins the SignalR group.
    ///
    /// <para>
    /// Unlike <see cref="Reject"/> this does not <c>Context.Abort()</c>. An invalid token makes the
    /// whole connection untrustworthy, but a chat the caller does not belong to is a per-call
    /// authorization failure: the session stays valid for their own conversations. Aborting would
    /// also swallow the message - the connection dies before the error frame reaches the client, so
    /// the caller sees a cancelled task instead of the reason.
    /// </para>
    /// </summary>
    private async Task<Guid> RequireParticipant(string chatId)
    {
        var userId = await RequireValidCaller();

        using var scope = _serviceScopeFactory.CreateScope();
        var messageRepository = scope.ServiceProvider.GetRequiredService<IMessageRepository>();

        if (!await messageRepository.IsParticipantAsync(chatId, userId))
            throw new HubException("You are not a participant of this conversation.");

        return userId;
    }

    private Guid Reject(string reason)
    {
        Context.Abort();
        throw new HubException(reason);
    }
}
