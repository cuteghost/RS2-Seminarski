using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class Notification : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    [Required]
    public Guid UserId { get; set; }

    [Required]
    public NotificationType Type { get; set; }

    [Required]
    [MaxLength(120)]
    public string Title { get; set; } = string.Empty;

    [Required]
    [MaxLength(1000)]
    public string Body { get; set; } = string.Empty;

    public Guid? RelatedEntityId { get; set; }

    [Required]
    public DateTime CreatedAt { get; set; }

    public bool IsRead { get; set; }

    public DateTime? ReadAt { get; set; }

    public bool IsDeleted { get; set; }

    public virtual User? User { get; set; }
}
