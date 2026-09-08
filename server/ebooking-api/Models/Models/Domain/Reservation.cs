using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace Models.Domain;

public class Reservation : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }
    [Required]
    public int NumberOfGuests { get; set; }
    [Required]
    public DateTime StartDate { get; set; }
    [Required]
    public DateTime EndDate { get; set; }
    [ForeignKey("accommodation")]
    public Guid AccommodationId { get; set; }
    [ForeignKey("customer")]
    public Guid CustomerId { get; set; }
    public bool IsDeleted { get; set; } = false;
    public bool IsRated { get; set; } = false;

    /// <summary>
    /// Stanje rezervacije. Mijenja se isključivo kroz <c>IReservationService</c>, koji provjerava
    /// da li je prelaz dozvoljen i upisuje red u <see cref="ReservationStatusHistory"/>.
    /// Brisanje reda umjesto promjene stanja je greška.
    /// </summary>
    [Required]
    public ReservationStatus Status { get; set; } = ReservationStatus.Pending;

    public DateTime? StatusChangedAt { get; set; }

    [MaxLength(500)]
    public string? StatusReason { get; set; }

    [Column(TypeName = "decimal(10,2)")]
    public decimal PricePerNight { get; set; }

    [Column(TypeName = "decimal(10,2)")]
    public decimal TotalPrice { get; set; }

    public virtual Accommodation accommodation { get; set; }
    public virtual Customer customer { get; set; }
}
