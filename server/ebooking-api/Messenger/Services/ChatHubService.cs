using Authentication.Services.TokenHandlerService;
using AutoMapper;
using Database.Services.MessagingService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Models.Constants;
using Models.Domain;
using Models.DTO.MessengerDTO;
using System.Security.Claims;

namespace Messenger;

[Authorize]
public class ChatHub : Hub
{
    public const int DefaultMessagePageSize = 30;

    private readonly IMapper _mapper;
    private readonly IMessageRepository _messageRepository;
    private readonly ITokenHandlerService _tokenHandlerService;

    public ChatHub(IMapper mapper, IMessageRepository messageRepository, ITokenHandlerService tokenHandlerService)
    {
        _mapper = mapper;
        _messageRepository = messageRepository;
        _tokenHandlerService = tokenHandlerService;
    }

    public override async Task OnConnectedAsync()
    {
        await RequireValidCaller();
        await base.OnConnectedAsync();
    }

    public async Task SendMessage(MessagePOST messageDto)
    {
        var content = messageDto.Content?.Trim() ?? string.Empty;
        if (content.Length == 0)
            throw new HubException("The message is empty.");

        if (content.Length > MessageRepository.MaxMessageLength)
            throw new HubException($"The message may have at most {MessageRepository.MaxMessageLength} characters.");

        var (userId, chat) = await RequireParticipant(messageDto.ChatId);

        var message = await _messageRepository.AddAsync(chat.Id, userId, content);

        var forSender = _mapper.Map<MessageGET>(message);
        forSender.isCurrent = true;

        var forRecipient = _mapper.Map<MessageGET>(message);
        forRecipient.isCurrent = false;

        var recipientId = chat.User1Id == userId ? chat.User2Id : chat.User1Id;

        await Clients.User(userId.ToString()).SendAsync("ReceiveMessage", forSender);
        await Clients.User(recipientId.ToString()).SendAsync("ReceiveMessage", forRecipient);
    }

    public async Task<List<ChatGET>> GetChats()
    {
        var userId = await RequireValidCaller();

        return await _messageRepository.GetChatSummariesAsync(userId);
    }

    public async Task<ChatGET> OpenChat(Guid otherUserId)
    {
        var userId = await RequireValidCaller();

        if (otherUserId == userId)
            throw new HubException("You cannot open a conversation with yourself.");

        var chat = await _messageRepository.GetOrCreateChatAsync(userId, otherUserId);
        if (chat == null)
            throw new HubException($"User with identifier {otherUserId} does not exist.");

        var summaries = await _messageRepository.GetChatSummariesAsync(userId);
        return summaries.First(c => c.Id == chat.Id);
    }

    public async Task<PagedMessagesGET> GetMessages(Guid chatId, int page, int pageSize)
    {
        var (userId, _) = await RequireParticipant(chatId);
        (page, pageSize) = Pagination.Normalize(page, pageSize <= 0 ? DefaultMessagePageSize : pageSize);

        var (items, totalCount) = await _messageRepository.GetMessagesAsync(chatId, page, pageSize);

        var messages = _mapper.Map<List<MessageGET>>(items);
        foreach (var message in messages)
            message.isCurrent = message.SenderId == userId;

        return new PagedMessagesGET
        {
            Items = messages,
            Page = page,
            PageSize = pageSize,
            TotalCount = totalCount,
            HasMore = page * pageSize < totalCount
        };
    }

    public async Task ReadMessages(Guid chatId)
    {
        var (userId, chat) = await RequireParticipant(chatId);

        var changed = await _messageRepository.MarkReadAsync(chatId, userId);
        if (changed.Count == 0)
            return;

        var senderId = chat.User1Id == userId ? chat.User2Id : chat.User1Id;
        var mapped = _mapper.Map<List<MessageGET>>(changed);
        foreach (var message in mapped)
            message.isCurrent = true;

        await Clients.User(senderId.ToString()).SendAsync("ReadMessages", mapped);
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

        if (!await _tokenHandlerService.IsTokenVersionValid(userId, version))
            return Reject("The token was revoked by logout or the account no longer exists. Please log in again.");

        return userId;
    }

    private async Task<(Guid UserId, Chat Chat)> RequireParticipant(Guid chatId)
    {
        var userId = await RequireValidCaller();

        var chat = await _messageRepository.GetChatAsync(chatId);
        if (chat == null || (chat.User1Id != userId && chat.User2Id != userId))
            throw new HubException("You are not a participant of this conversation.");

        return (userId, chat);
    }

    private Guid Reject(string reason)
    {
        Context.Abort();
        throw new HubException(reason);
    }
}
