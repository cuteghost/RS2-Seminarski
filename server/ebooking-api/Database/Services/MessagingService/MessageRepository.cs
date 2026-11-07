using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Models.DTO.MessengerDTO;

namespace Database.Services.MessagingService;

public class MessageRepository : IMessageRepository
{
    public const int MaxMessageLength = 2000;

    private readonly ApplicationDbContext _context;

    public MessageRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Message> AddAsync(Guid chatId, Guid senderId, string content)
    {
        var message = new Message
        {
            Id = Guid.NewGuid(),
            ChatId = chatId,
            SenderId = senderId,
            Content = content,
            Timestamp = DateTime.UtcNow,
            IsRead = false
        };

        _context.Messages.Add(message);
        await _context.SaveChangesAsync();

        return message;
    }

    public async Task<List<ChatGET>> GetChatSummariesAsync(Guid userId)
    {
        var rows = await _context.Chats
            .AsNoTracking()
            .Where(c => c.User1Id == userId || c.User2Id == userId)
            .Select(c => new
            {
                c.Id,
                c.User1Id,
                c.User2Id,
                User1Name = c.User1!.DisplayName,
                User2Name = c.User2!.DisplayName,
                LastMessage = c.Messages
                    .OrderByDescending(m => m.Timestamp)
                    .Select(m => new MessageGET
                    {
                        Content = m.Content,
                        TimeStamp = m.Timestamp,
                        SenderId = m.SenderId,
                        ChatId = m.ChatId,
                        IsRead = m.IsRead
                    })
                    .FirstOrDefault(),
                UnreadCount = c.Messages.Count(m => !m.IsRead && m.SenderId != userId)
            })
            .ToListAsync();

        return rows
            .Select(row =>
            {
                var isFirst = row.User1Id == userId;
                if (row.LastMessage != null)
                    row.LastMessage.isCurrent = row.LastMessage.SenderId == userId;

                return new ChatGET
                {
                    Id = row.Id,
                    User1Id = isFirst ? row.User1Id : row.User2Id,
                    User2Id = isFirst ? row.User2Id : row.User1Id,
                    User1 = isFirst ? row.User1Name : row.User2Name,
                    User2 = isFirst ? row.User2Name : row.User1Name,
                    LastMessage = row.LastMessage,
                    UnreadCount = row.UnreadCount
                };
            })
            .OrderByDescending(chat => chat.LastMessage?.TimeStamp ?? DateTime.MinValue)
            .ToList();
    }

    public async Task<(List<Message> Items, int TotalCount)> GetMessagesAsync(Guid chatId, int page, int pageSize)
    {
        var query = _context.Messages
            .AsNoTracking()
            .Where(m => m.ChatId == chatId);

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderByDescending(m => m.Timestamp)
            .ThenByDescending(m => m.Id)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        items.Reverse();

        return (items, totalCount);
    }

    public async Task<List<Message>> MarkReadAsync(Guid chatId, Guid readerId)
    {
        var unread = await _context.Messages
            .Where(m => m.ChatId == chatId && !m.IsRead && m.SenderId != readerId)
            .ToListAsync();

        if (unread.Count == 0)
            return unread;

        foreach (var message in unread)
            message.IsRead = true;

        await _context.SaveChangesAsync();
        return unread;
    }

    public async Task<bool> IsParticipantAsync(Guid chatId, Guid userId)
    {
        return await _context.Chats
            .AsNoTracking()
            .AnyAsync(c => c.Id == chatId && (c.User1Id == userId || c.User2Id == userId));
    }

    public async Task<Chat?> GetChatAsync(Guid chatId)
    {
        return await _context.Chats
            .AsNoTracking()
            .Include(c => c.User1)
            .Include(c => c.User2)
            .FirstOrDefaultAsync(c => c.Id == chatId);
    }

    public async Task<Chat?> GetOrCreateChatAsync(Guid callerId, Guid otherUserId)
    {
        if (callerId == otherUserId)
            return null;

        var existing = await _context.Chats
            .Include(c => c.User1)
            .Include(c => c.User2)
            .FirstOrDefaultAsync(c =>
                (c.User1Id == callerId && c.User2Id == otherUserId) ||
                (c.User1Id == otherUserId && c.User2Id == callerId));

        if (existing != null)
            return existing;

        var users = await _context.Users
            .Where(u => (u.Id == callerId || u.Id == otherUserId) && !u.IsDeleted)
            .ToListAsync();

        if (users.Count != 2)
            return null;

        var chat = new Chat
        {
            Id = Guid.NewGuid(),
            User1Id = callerId,
            User2Id = otherUserId,
        };

        _context.Chats.Add(chat);
        await _context.SaveChangesAsync();

        chat.User1 = users.First(u => u.Id == callerId);
        chat.User2 = users.First(u => u.Id == otherUserId);

        return chat;
    }
}
