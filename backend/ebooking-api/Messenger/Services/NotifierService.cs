
using AutoMapper;
using Messenger.Repositories;
using Messenger.Repository;
using Microsoft.AspNetCore.SignalR;
using Models.Domain;
using Models.DTO.MessengerDTO;

namespace Messenger;

public class NotifierService : INotifierService
{
    private readonly IHubContext<ChatHub> _hubContext;
    private readonly IMessageRepository _messageRepository;
    private readonly IMapper _mapper;
    private readonly IServiceProvider _serviceProvider;

    public NotifierService(IHubContext<ChatHub> hubContext, IMessageRepository messageRepository, IMapper mapper, IServiceProvider serviceProvider)
    {
        _hubContext = hubContext;
        _messageRepository = messageRepository;
        _mapper = mapper;
        _serviceProvider = serviceProvider;
    }

    public async Task Notify(WelcomeMessage welcomeMessage)
    {
        using (var scope = _serviceProvider.CreateScope())
        {
            var chats = await _messageRepository.GetChatsAsync(welcomeMessage.User1Id);
            var chatId = Guid.Empty;
            foreach (var chat in chats)
            {
                if (chat.User1Id == welcomeMessage.User1Id && chat.User2Id == welcomeMessage.User2Id || chat.User1Id == welcomeMessage.User2Id && chat.User2Id == welcomeMessage.User1Id)
                {
                    chatId = chat.Id;
                    break;
                }
            }
            if (chatId == Guid.Empty)
            {
                chatId = Guid.NewGuid();
                await _messageRepository.CreateChatAsync(new Chat
                {
                    Id = chatId,
                    User1Id = welcomeMessage.User1Id,
                    User2Id = welcomeMessage.User2Id
                });



            }
            var messageDto = new MessagePOST { ChatId = chatId, Content = welcomeMessage.Message, SenderId = welcomeMessage.User1Id, Timestamp = welcomeMessage.TimeStamp };
            var message = _mapper.Map<Message>(messageDto);
            _messageRepository.Add(message);
            var messageGET = _mapper.Map<MessageGET>(message);
            messageGET.isCurrent = false;
            messageGET.IsRead = false;

            await _hubContext.Groups.AddToGroupAsync(welcomeMessage.User2Id.ToString(), chatId.ToString());
            await _hubContext.Clients.Group(chatId.ToString()).SendAsync("ReceiveMessage", messageGET);
            await _hubContext.Groups.RemoveFromGroupAsync(welcomeMessage.User2Id.ToString(), chatId.ToString());
        }

    }
}
