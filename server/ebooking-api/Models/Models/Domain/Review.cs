using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Models.Domain;

public class Review : ISoftDeleted
{
    [Key]
    [Column(TypeName = "uniqueidentifier")]
    public Guid Id { get; set; }

    [Required]
    [ForeignKey("Customer")]
    public Guid CustomerId { get; set; }

    [Required]
    [ForeignKey("Accommodation")]
    public Guid AccommodationId { get; set; }

    [Required]
    public int Rating { get; set; }

    [Required]
    public bool Satisfaction { get; set; } = false;


    [Required]
    public bool WouldRecommend { get; set; } = false;

    public string Comment { get; set; } = string.Empty;

    public virtual Customer Customer { get; set; }
    public virtual Accommodation Accommodation { get; set; }
    public bool IsDeleted { get; set; }
}