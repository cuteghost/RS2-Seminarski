using Authentication.Services.TokenHandlerService;
using AutoMapper;
using Database;
using Messenger.Repositories;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Models.DTO.MessengerDTO;

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
        await Groups.AddToGroupAsync(Context.ConnectionId, chatId);
    }

    public async Task SendMessage(MessagePOST messageDto)
    {
        var token = Context.GetHttpContext().Request.Headers["Authorization"].ToString();
        if(token == null || token == String.Empty)
        {
            throw new Exception("Unauthorized");
        }
        using var scope = _serviceScopeFactory.CreateScope();
        var tokenHandlerService = scope.ServiceProvider.GetRequiredService<ITokenHandlerService>();
        var userId = tokenHandlerService.GetUserIdFromJWT(token);
        messageDto.SenderId = userId;
        
        var message = _mapper.Map<Message>(messageDto);
        var messageRepository = scope.ServiceProvider.GetRequiredService<IMessageRepository>();
        
        messageRepository.Add(message);
        MessageGET messageGET = _mapper.Map<MessageGET>(message);
        messageGET.isCurrent = false;
        var chatId = message.ChatId.ToString();

        await Clients.Group(chatId).SendAsync("ReceiveMessage", messageGET);
    }

    public async Task<List<ChatGET>> GetChats()
    {
        var token = Context.GetHttpContext().Request.Headers["Authorization"].ToString();
        try
        {
            using var scope = _serviceScopeFactory.CreateScope();
            var tokenHandlerService = scope.ServiceProvider.GetRequiredService<ITokenHandlerService>();
            var userId = tokenHandlerService.GetUserIdFromJWT(token);
            var messageRepository = scope.ServiceProvider.GetRequiredService<IMessageRepository>();
            var chats = await messageRepository.GetChatsAsync(userId);
            List<ChatGET> chatsDto = new();
            foreach (var chat in chats)
            {
                if (chat.User1Id == userId)
                {
                    chatsDto.Add(new ChatGET
                    {
                        Id = chat.Id,
                        User1 = chat.User1.DisplayName,
                        User2 = chat.User2.DisplayName,
                        Messages = _mapper.Map<List<MessageGET>>(chat.Messages.OrderByDescending(m => m.Timestamp))
                    });
                }
                else
                {
                    chatsDto.Add(new ChatGET
                    {
                        Id = chat.Id,
                        User1 = chat.User2.DisplayName,
                        User2 = chat.User1.DisplayName,
                        Messages = _mapper.Map<List<MessageGET>>(chat.Messages.OrderByDescending(m => m.Timestamp))
                    });
                }
            }
            return chatsDto;
        }
        catch (Exception e)
        {
            throw new Exception("Unauthorized");
        }
    }

    public async Task InitChat(string chatId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, chatId);
    }


    public async Task<List<MessageGET>> GetMessages(string chatId)
    {
        var token = Context.GetHttpContext().Request.Headers["Authorization"].ToString();
        if (token == null || token == String.Empty)
        {
            throw new Exception("Unauthorized");
        }
        using var scope = _serviceScopeFactory.CreateScope();
        var tokenHandlerService = scope.ServiceProvider.GetRequiredService<ITokenHandlerService>();
        var messageRepository = scope.ServiceProvider.GetRequiredService<IMessageRepository>();
        var messages =  _mapper.Map<List<MessageGET>>(await messageRepository.GetMessagesAsync(chatId));
        foreach(var m in messages)
        {
            m.isCurrent = m.SenderId == tokenHandlerService.GetUserIdFromJWT(token);
        }
        return messages;
    }
    public async Task ReadMessages(string chatId)
    {
           var token = Context.GetHttpContext().Request.Headers["Authorization"].ToString();
        if (token == null || token == String.Empty)
        {
            throw new Exception("Unauthorized");
        }
        using var scope = _serviceScopeFactory.CreateScope();
        var tokenHandlerService = scope.ServiceProvider.GetRequiredService<ITokenHandlerService>();
        var messageRepository = scope.ServiceProvider.GetRequiredService<IMessageRepository>();
        var userId = tokenHandlerService.GetUserIdFromJWT(token);
        var messages = await messageRepository.ReadMessages(chatId, userId);
        await Clients.Group(chatId).SendAsync("ReadMessages", _mapper.Map<List<MessageGET>>(messages));
    }
    public async Task AddToGroup(string chatId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, chatId);
    }

    public async Task RemoveFromGroup(string chatId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, chatId);
    }
}