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
    public DateTime StartDate { get; set;}
    [Required]
    public DateTime EndDate { get; set; }
    [ForeignKey("accommodation")]
    public Guid AccommodationId { get; set; }
    [ForeignKey("customer")]
    public Guid CustomerId { get; set; }
    public bool IsDeleted { get; set; } = false;
    public bool IsRated { get; set; } = false;

    public virtual Accommodation accommodation { get; set; }
    public virtual Customer customer { get; set; }
}
