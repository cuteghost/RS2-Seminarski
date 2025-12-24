using Database;
using Messenger.Repositories;
using Microsoft.EntityFrameworkCore;
using Models.Domain;

namespace Messenger.Repository;

public class MessageRepository : IMessageRepository
{
    private readonly ApplicationDbContext _context;

    public MessageRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public IEnumerable<Message> GetAll() => _context.Messages.ToList();

    public Message GetById(Guid id) => _context.Messages.FirstOrDefault(m => m.Id == id);

    public void Add(Message message)
    {
        message.Id = Guid.NewGuid();
        message.Timestamp = DateTime.Now;
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
        catch (Exception)
        {

            return false;
        }
    }

    public async Task<List<Chat>> GetChatsAsync(Guid userId)
    {
        List<Chat> toReturn = new();
        try{
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
        catch (Exception)
        {
            
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
}
