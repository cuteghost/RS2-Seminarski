using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class PasswordResetToken : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    [Required]
    public Guid UserId { get; set; }

    [Required]
    [MaxLength(200)]
    public string CodeHash { get; set; } = string.Empty;

    [Required]
    public DateTime CreatedAt { get; set; }

    [Required]
    public DateTime ExpiresAt { get; set; }

    public DateTime? UsedAt { get; set; }

    public int FailedAttempts { get; set; }

    public bool IsDeleted { get; set; }

    public virtual User? User { get; set; }
}
