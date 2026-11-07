using API.Exceptions;
using Microsoft.EntityFrameworkCore;
using Models.Domain;
using Models.DTO.NotificationDTO;

namespace Database.Services.NotificationService;

public class NotificationService : INotificationService
{
    private readonly ApplicationDbContext _context;

    public NotificationService(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<(List<NotificationGET> Items, int TotalCount)> GetForUser(Guid userId, bool unreadOnly, int page, int pageSize)
    {
        var query = _context.Notifications
            .AsNoTracking()
            .Where(n => n.UserId == userId && !n.IsDeleted);

        if (unreadOnly)
            query = query.Where(n => !n.IsRead);

        var totalCount = await query.CountAsync();

        var items = await query
            .OrderByDescending(n => n.CreatedAt)
            .ThenBy(n => n.Id)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(n => new NotificationGET
            {
                Id = n.Id,
                Type = n.Type,
                Title = n.Title,
                Body = n.Body,
                RelatedEntityId = n.RelatedEntityId,
                CreatedAt = n.CreatedAt,
                IsRead = n.IsRead,
                ReadAt = n.ReadAt
            })
            .ToListAsync();

        return (items, totalCount);
    }

    public Task<int> CountUnread(Guid userId)
    {
        return _context.Notifications.CountAsync(n => n.UserId == userId && !n.IsDeleted && !n.IsRead);
    }

    public async Task<NotificationGET> MarkRead(Guid userId, Guid notificationId)
    {
        var notification = await _context.Notifications
            .FirstOrDefaultAsync(n => n.Id == notificationId && !n.IsDeleted);

        if (notification == null || notification.UserId != userId)
            throw new NotFoundException($"Notification with identifier {notificationId} does not exist.");

        if (!notification.IsRead)
        {
            notification.IsRead = true;
            notification.ReadAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }

        return new NotificationGET
        {
            Id = notification.Id,
            Type = notification.Type,
            Title = notification.Title,
            Body = notification.Body,
            RelatedEntityId = notification.RelatedEntityId,
            CreatedAt = notification.CreatedAt,
            IsRead = notification.IsRead,
            ReadAt = notification.ReadAt
        };
    }

    public async Task<int> MarkAllRead(Guid userId)
    {
        var now = DateTime.UtcNow;

        return await _context.Notifications
            .Where(n => n.UserId == userId && !n.IsDeleted && !n.IsRead)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(n => n.IsRead, true)
                .SetProperty(n => n.ReadAt, now));
    }
}
