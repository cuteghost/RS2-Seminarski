using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class Payment : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    [ForeignKey("Reservation")]
    public Guid ReservationId { get; set; }

    [Column(TypeName = "decimal(10,2)")]
    public decimal Amount { get; set; }

    [Required]
    [MaxLength(3)]
    public string Currency { get; set; } = "USD";

    [Required]
    public PaymentStatus Status { get; set; } = PaymentStatus.Created;

    [Required]
    [MaxLength(20)]
    public string Provider { get; set; } = "PayPal";

    [MaxLength(64)]
    public string? ProviderOrderId { get; set; }

    [MaxLength(64)]
    public string? ProviderCaptureId { get; set; }

    [Required]
    public DateTime CreatedAt { get; set; }

    public DateTime? CompletedAt { get; set; }

    [MaxLength(500)]
    public string? FailureReason { get; set; }

    public bool IsDeleted { get; set; } = false;

    public virtual Reservation? Reservation { get; set; }
}
