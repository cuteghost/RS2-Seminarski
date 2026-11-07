using Database;
using Microsoft.EntityFrameworkCore;
using Models.Domain;

namespace EBooking.Worker.Handlers;

public class NotificationHandler
{
    private const int TitleMaxLength = 120;
    private const int BodyMaxLength = 1000;

    private readonly ApplicationDbContext _context;
    private readonly ILogger<NotificationHandler> _logger;

    public NotificationHandler(ApplicationDbContext context, ILogger<NotificationHandler> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task Handle(NotificationEvent notificationEvent)
    {
        if (!await _context.Users.AnyAsync(u => u.Id == notificationEvent.UserId && !u.IsDeleted))
        {
            _logger.LogWarning("Notifikacija {Type} je odbačena jer korisnik {UserId} ne postoji.",
                notificationEvent.Type, notificationEvent.UserId);
            return;
        }

        _context.Notifications.Add(new Notification
        {
            Id = Guid.NewGuid(),
            UserId = notificationEvent.UserId,
            Type = notificationEvent.Type,
            Title = Clip(notificationEvent.Title, TitleMaxLength),
            Body = Clip(notificationEvent.Body, BodyMaxLength),
            RelatedEntityId = notificationEvent.RelatedEntityId,
            CreatedAt = notificationEvent.CreatedAt == default ? DateTime.UtcNow : notificationEvent.CreatedAt,
            IsRead = false,
            IsDeleted = false
        });

        await _context.SaveChangesAsync();
    }

    private static string Clip(string value, int maxLength) =>
        value.Length > maxLength ? value[..maxLength] : value;
}
