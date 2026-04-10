using Models.Domain;

namespace Messenger.Repositories;

public interface IMessageRepository
{
    void Add(Message message);
    Task<bool> CreateChatAsync(Chat chat);
    Task<List<Chat>> GetChatsAsync(Guid userId);
    Task<List<Message>> GetMessagesAsync(string chatId);
    Task<List<Message>> ReadMessages(string chatId, Guid userId);
    Task<Chat?> GetOrCreateChatAsync(Guid callerId, Guid otherUserId);

    Task<bool> IsParticipantAsync(string chatId, Guid userId);
}