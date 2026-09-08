using Database;
using Messenger.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Models.Domain;

namespace Messenger.Repository;

public class MessageRepository : IMessageRepository
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<MessageRepository> _logger;

    public MessageRepository(ApplicationDbContext context, ILogger<MessageRepository> logger)
    {
        _context = context;
        _logger = logger;
    }

    public IEnumerable<Message> GetAll() => _context.Messages.ToList();

    public Message GetById(Guid id) => _context.Messages.FirstOrDefault(m => m.Id == id);

    public void Add(Message message)
    {
        message.Id = Guid.NewGuid();
        message.Timestamp = DateTime.UtcNow;
        _context.Messages.Add(message);
        _context.SaveChanges();
    }

    public async Task<bool> CreateChatAsync(Chat chat)
    {
        try
        {
            var chats = await _context.Chats.ToListAsync();
            foreach (var c in chats)
            {
                if ((c.User1 == chat.User1 && c.User2 == chat.User2) || (c.User1 == chat.User2 && c.User2 == chat.User1))
                {
                    return false;
                }
            }
            _context.Chats.Add(chat);
            await _context.SaveChangesAsync();
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Kreiranje razgovora izmedju {User1Id} i {User2Id} nije uspjelo.",
                chat.User1Id, chat.User2Id);
            return false;
        }
    }

    public async Task<List<Chat>> GetChatsAsync(Guid userId)
    {
        List<Chat> toReturn = new();
        try
        {
            var chats = await _context.Chats
                              .Include(c => c.User1)
                              .Include(c => c.User2)
                              .Include(c => c.Messages)
                              .ToListAsync();
            foreach (var chat in chats)
            {
                if (chat.User1Id == userId || chat.User2Id == userId)
                {
                    toReturn.Add(chat);
                }
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Ucitavanje razgovora korisnika {UserId} nije uspjelo; vraca se {Count} razgovora.",
                userId, toReturn.Count);
        }
        return toReturn;
    }

    public async Task<List<Message>> GetMessagesAsync(string chatId)
    {
        return await _context.Messages.Where(m => m.ChatId.ToString() == chatId).OrderBy(m => m.Timestamp).ToListAsync();
    }

    public async Task<List<Message>> ReadMessages(string chatId, Guid userId)
    {
        var messages = await _context.Messages.Where(m => m.ChatId.ToString() == chatId.ToString()).OrderByDescending(m => m.Timestamp).ToListAsync();
        foreach (var message in messages)
            if (message.SenderId != userId)
                message.IsRead = true;

        await _context.SaveChangesAsync();
        return messages;
    }

    public async Task<bool> IsParticipantAsync(string chatId, Guid userId)
    {
        if (!Guid.TryParse(chatId, out var id))
            return false;

        return await _context.Chats
            .AsNoTracking()
            .AnyAsync(c => c.Id == id && (c.User1Id == userId || c.User2Id == userId));
    }

    public async Task<Chat?> GetOrCreateChatAsync(Guid callerId, Guid otherUserId)
    {
        var existing = await _context.Chats
            .Include(c => c.User1)
            .Include(c => c.User2)
            .FirstOrDefaultAsync(c =>
                (c.User1Id == callerId && c.User2Id == otherUserId) ||
                (c.User1Id == otherUserId && c.User2Id == callerId));

        if (existing != null)
            return existing;

        var otherUserExists = await _context.Users.AnyAsync(u => u.Id == otherUserId && !u.IsDeleted);
        if (!otherUserExists)
            return null;

        var chat = new Chat
        {
            Id = Guid.NewGuid(),
            User1Id = callerId,
            User2Id = otherUserId,
        };
        _context.Chats.Add(chat);
        await _context.SaveChangesAsync();

        chat.User1 = await _context.Users.FirstAsync(u => u.Id == callerId);
        chat.User2 = await _context.Users.FirstAsync(u => u.Id == otherUserId);

        return chat;
    }
}
