using Models.Domain;
using Models.DTO.MessengerDTO;

namespace Messenger;

public interface IChatHub
{
    Task<List<MessageGET>> GetMessages(string chatId);
    Task<List<ChatGET>> GetChats();
    Task SendMessage(MessagePOST messageDto);
    Task AddToChat(string chatId);
}
