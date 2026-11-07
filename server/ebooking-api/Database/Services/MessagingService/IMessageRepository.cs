using Models.Domain;
using Models.DTO.MessengerDTO;

namespace Database.Services.MessagingService;

public interface IMessageRepository
{
    Task<Message> AddAsync(Guid chatId, Guid senderId, string content);

    Task<List<ChatGET>> GetChatSummariesAsync(Guid userId);

    Task<(List<Message> Items, int TotalCount)> GetMessagesAsync(Guid chatId, int page, int pageSize);

    Task<List<Message>> MarkReadAsync(Guid chatId, Guid readerId);

    Task<Chat?> GetOrCreateChatAsync(Guid callerId, Guid otherUserId);

    Task<Chat?> GetChatAsync(Guid chatId);

    Task<bool> IsParticipantAsync(Guid chatId, Guid userId);
}
