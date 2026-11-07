using Models.Domain;

namespace Models.DTO.NotificationDTO;

public class NotificationGET
{
    public Guid Id { get; set; }
    public NotificationType Type { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public Guid? RelatedEntityId { get; set; }
    public DateTime CreatedAt { get; set; }
    public bool IsRead { get; set; }
    public DateTime? ReadAt { get; set; }
}
