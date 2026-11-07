using Models.DTO.NotificationDTO;

namespace Database.Services.NotificationService;

public interface INotificationService
{
    Task<(List<NotificationGET> Items, int TotalCount)> GetForUser(Guid userId, bool unreadOnly, int page, int pageSize);

    Task<int> CountUnread(Guid userId);

    Task<NotificationGET> MarkRead(Guid userId, Guid notificationId);

    Task<int> MarkAllRead(Guid userId);
}
